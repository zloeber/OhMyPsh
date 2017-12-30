Function Remove-OMPPlugin {
    <#
    .SYNOPSIS
    Removes a loaded plugin
    .DESCRIPTION
    Removes a loaded plugin
    .PARAMETER NoProfileUpdate
    Skip updating the profile
    .PARAMETER Force
    Attempt to remove a plugin that doesn't show as being loaded
    .EXAMPLE
    Remove-OMPPlugin -Name o365
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param (
        [Parameter()]
        [switch]$Force,
        [Parameter()]
        [switch]$NoProfileUpdate
    )
    dynamicparam {
        # Create dictionary
        $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $NewParamSettings = @{
            Name = 'Name'
            Position = 0
            Type = 'string'
            HelpMessage = 'The plugin to remove.'
            ValueFromPipeline = $true
            ValueFromPipelineByPropertyName = $true
        }
        $NewParamSettings.ValidateSet = @($Script:OMPState['PluginsLoaded'])
        if ((@($Script:OMPState['PluginsLoaded']).Count -gt 0) -and (-not $force)) {
            $NewParamSettings.ValidateSet = (Get-OMPProfileSetting).Plugins
        }

        # Add new dynamic parameter to dictionary
        New-DynamicParameter @NewParamSettings -Dictionary $DynamicParameters

        # Return dictionary with dynamic parameters
        $DynamicParameters
    }
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    process {
        # Pull in the dynamic parameters first
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

        $LoadedPlugins = $Script:OMPState['PluginsLoaded']

        if (-not [string]::IsNullOrEmpty($Name)) {
            if ((@($Script:OMPState['PluginsLoaded']) -contains $Name) -or $Force) {
                $Unload = $null
                $PluginPath = (Get-OMPPlugin | Where {$_.Name -eq $Name}).Path
                $UnloadScript = Join-Path $PluginPath 'Load.ps1'

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
}