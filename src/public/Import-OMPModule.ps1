Function Import-OMPModule {
    <#
    .SYNOPSIS
        Attempt to load and optionally install a powershell module.
    .DESCRIPTION
        Attempt to load and optionally install a powershell module.
    .PARAMETER Name
        Name of the module
    .EXAMPLE
        PS> Import-OMPModule -Name 'posh-git'

        If not already imported attempt to import posh-git. 
        If the OhMyPsh profile allows, attempt to automatically install posh-git if it isn't found.
    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Name
    )
    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        $AllModules = @()
    }
    Process {
        $AllModules += $Name
    }
    End {
        Foreach ($Module in $AllModules) {
            if ((get-module $Module -ListAvailable) -eq $null) {
                if ($Script:OMPProfile['AutoInstallModules']) {
                    Write-Verbose "Attempting to install missing module: $($Module)"
                    try {
                        $null = Install-Module $Module -Scope:CurrentUser
                        Write-Verbose "Module Installed: $($Module)"
                    }
                    catch {
                        throw "Unable to find or install the following module requirement: $($Module)"
                    }
                }
                else {
                    throw "$($Module) was not found and automatic installation of modules is disabled in this profile!"
                }
            }

            # If we made it this far and the module isn't loaded, try to do so now
            if (-not (get-module $Module)) {
                Write-Verbose "Attempting to import module: $Module"
                Import-Module $Module -Global -force
            }
            else {
                Write-Verbose "$Module is already loaded"
                return
            }

            # check if it loaded properly
            if (-not (get-module $Module)) {
                throw "$($Module) was not able to load!"
            }
            else {
                Write-Verbose "Module Imported: $Module"
            }
        }
    }
}