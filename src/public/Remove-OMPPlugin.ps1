Function Remove-OMPPlugin {
    <#
    .SYNOPSIS
        Removes a loaded plugin
    .DESCRIPTION
        Removes a loaded plugin
    .PARAMETER Name
        Name of the plugin
    .PARAMETER Force   
        If the plugin is already loaded use this to force load it again.
    .PARAMETER NoProfileUpdate
        Skip updating the profile
    .EXAMPLE
        PS> Remove-OMPPlugin -Name 'o365'

    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name,
        [Parameter(Position = 1)]
        [switch]$Force,
        [Parameter(Position = 2)]
        [switch]$NoProfileUpdate
    )

    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        Write-Verbose "Attempting to load the plugin $Name"
    }

    Process {
        $LoadedPlugins = $Script:OMPState['PluginsLoaded']
        if (($LoadedPlugins -contains $Name) -or $Force) {
            $Unload = $null
            $PluginPath = (Get-OMPPlugin | Where {$_.Name -eq $Name}).Path
            $UnloadScript = Join-Path $PluginPath 'UnLoad.ps1'

            if (Test-Path $UnloadScript) {
                Write-Verbose "Executing plugin unload script: $UnloadScript"

                # pull in the unload definition
                $sb = [Scriptblock]::create(".{$(Get-Content -Path $UnloadScript -Raw)}")
                Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
                if (-not ([string]::IsNullOrEmpty($errmsg))) {
                    Write-Warning "Unable to unload plugin - $Name"
                    Write-Warning "Error: $($errmsg | Select *)"
                    throw
                }
            
                # Run unload plugin code
                $Unloadsb = [Scriptblock]::create(".{$Unload}")
                Invoke-Command -NoNewScope -ScriptBlock $Unloadsb -ErrorVariable errmsg 2>$null
                if (-not ([string]::IsNullOrEmpty($errmsg))) {
                    Write-Warning "Unable to unload plugin - $Name"
                    Write-Warning "Error: $($errmsg | Select *)"
                    throw
                }
            }
            else {
                Write-Verbose "No unload file found for plugin - $Name"
            }

            # If we made it this far then update our loaded plugins list to remove the plugin
            $Script:OMPState['PluginsLoaded'] = @($LoadedPlugins | Where-Object {$_ -ne $Name} | Sort-Object -Unique)

            if (-not $NoProfileUpdate) {
                try {
                    $Script:OMPProfile['Plugins'] = @($Script:OMPProfile['Plugins'] | Where-Object {$_ -ne $Name} | Sort-Object -Unique)
                    Export-OMPProfile
                }
                catch {
                    throw "Unable to update or save the profile!"
                }
            }
        }
        else {
            Write-Output "$Name is not loaded in this session. Use the -Force parameter to try to unload it regardless."
        }
    }
}