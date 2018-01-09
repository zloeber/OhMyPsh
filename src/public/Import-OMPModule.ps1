Function Import-OMPModule {
    <#
    .SYNOPSIS
    Attempt to load and optionally install a powershell module.
    .DESCRIPTION
    Attempt to load and optionally install a powershell module. By default all installed modules are scoped to the current user.
    .PARAMETER Name
    Name of the module
    .PARAMETER Prefix
    Prefix commands imported.
    .EXAMPLE
    PS> Import-OMPModule -Name 'posh-git'

    If not already imported attempt to import posh-git.
    If the OhMyPsh profile allows, attempt to automatically install posh-git if it isn't found.
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Name,
        [Parameter()]
        [string]$Prefix
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."

        $AllModules = @()
        $ImportSplat = $Script:OMPProfile['OMPModuleInstallSplat']
        if (-not [string]::IsNullOrEmpty($Prefix)) {
            $ImportSplat.Prefix = $Prefix
        }
        if ($Force) {
            $ImportSplat.Force = $true
        }
    }
    Process {
        $AllModules += $Name
    }
    End {
        Foreach ($Module in $AllModules) {
            if ( $null -eq (Get-Module $Module -ListAvailable) ) {
                if ($Script:OMPProfile['AutoInstallModules']) {
                    Write-Verbose "$($FunctionName): Attempting to install missing module: $($Module)"
                    try {
                        Import-Module PowerShellGet -Force
                        $null = Install-Module $Module -Scope:CurrentUser
                        Write-Verbose "$($FunctionName): Module Installed - $($Module)"
                    }
                    catch {
                        throw "Unable to find or install the following module requirement: $($Module)"
                    }
                }
                else {
                    throw "$($Module) was not found and automatic installation of modules is disabled in this profile!"
                }
            }

            # If we made it this far and the module isn't loaded, try to do so now. We have to import globaly for it to show up in the calling user's session.
            if (-not (get-module $Module)) {
                Write-Verbose "$($FunctionName): Attempting to import module - $Module"
                Import-Module $Module -Global -force @ImportSplat
            }
            else {
                Write-Verbose "$($FunctionName): $Module is already loaded"
                return
            }

            # check if it loaded properly
            if (-not (get-module $Module)) {
                throw "$($Module) was not able to load!"
            }
            else {
                Write-Verbose "$($FunctionName): Module Imported - $Module"
            }
        }
    }
}