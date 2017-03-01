Function Invoke-OMPPluginShutdown {
    <#
    .SYNOPSIS
        Runs the shutdown code for a loaded plugin.
    .DESCRIPTION
        Runs the shutdown code for a loaded plugin.
    .PARAMETER Name
        Name of the plugin
    .EXAMPLE
        PS> Invoke-OMPPluginShutdown -Name 'o365'

    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$Name
    )

    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        Write-Verbose "Attempting to shutdown the plugin $Name"
    }

    Process {
        Foreach ($Plugin in (Get-OMPPlugin -Name $Name | Where {$_.Loaded})) {
            $LoadScript = Join-Path $Plugin.Path "Load.ps1"
            $Shutdown = $null
            if (-not (Test-Path $LoadScript)) {
                Write-Error "Unable to find the plugin load file: $LoadScript"
                return
            }
            
            Write-Verbose "Executing plugin load script: $LoadScript"
            # pull in the entire load script
            $errmsg = $null
            $sb = [Scriptblock]::create(".{$(Get-Content -Path $LoadScript -Raw)}")
            Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
            if (-not ([string]::IsNullOrEmpty($errmsg))) {
                Write-Warning "Unable to load plugin $($Plugin.Name)"
                Write-Warning "Error: $($errmsg | Select *)"
                return
            }
            
            # Run shutdown plugin code
            $errmsg = $null
            if ($Shutdown -ne $null) {
                $Shutdownsb = [Scriptblock]::create(".{$Shutdown}")
                Invoke-Command -NoNewScope -ScriptBlock $Shutdownsb -ErrorVariable errmsg 2>$null
                if (-not ([string]::IsNullOrEmpty($errmsg))) {
                    Write-Warning "Unable to run shutdown plugin code for $($Plugin.Name)"
                    Write-Warning "Error: $($errmsg | Select *)"
                    return
                }
            }
        }
    }
}