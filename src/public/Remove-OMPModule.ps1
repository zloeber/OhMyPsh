Function Remove-OMPModule {
    <#
    .SYNOPSIS
    Removes a module from this session.
    .DESCRIPTION
    Removes a module from this session.
    .PARAMETER Name
    Name of the module
    .PARAMETER PluginSafe
    If you are removing the module as part of a plugin use this switch to only unload a module if it isn't
    in the autoloaded modules OhMyPsh profile setting or loaded prior to OhMyPsh being started. Note that
    this is not 'safe' if there are multiple plugins loaded with the same module requirements.
    .EXAMPLE
    PS> Remove-OMPModule -Name 'posh-git' -PluginSafe

    Removes posh-git from this session if it was not autoloaded or loaded when OhMyPsh started.

    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string[]]$Name,
        [Parameter(Position = 1)]
        [switch]$PluginSafe
    )
    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        $AllModules = @()
        $PluginSafeArg = @{}
        if ($PluginSafe) {
            $PluginSafeArg.PluginSafe = $true
        }

    }
    Process {
        $AllModules += (Get-Module $Name).Name
    }
    End {
        Foreach ($Module in $AllModules) {
            # Recursively remove dependant modules first...
            $ModulesDependOnMe = @(Get-Module | Where {$_.RequiredModules -contains $Module})
            if ($ModulesDependOnMe.Count -gt 0) {
                Write-Verbose "Found $($ModulesDependOnMe.Count) other modules dependant upon $Module"
                $ModulesDependOnMe | ForEach-Object {
                    Write-Verbose "Recursively attempting to remove $($_) first..."
                    Remove-OMPModule -Name $_ @PluginSafeArg
                }
            }

            # if pluginsafe removal then only remove modules new since OMP started and not in our autoload module list.
            if ($PluginSafe) {
                $WasAlreadyLoaded = ($Script:OMPState['ModulesAlreadyLoaded'] -contains $Module)
                $IsAutoLoaded = ($Script:OMPProfile['AutoLoadModules' -contains $Module])

                if (-not ($WasAlreadyLoaded -or $IsAutoLoaded)) {
                    try {
                        Write-Verbose "Attempting to remove module: $Module"
                        Remove-Module -Name $Module -Force
                    }
                    catch {
                        throw "Unable to remove module $($Name)"
                    }
                }
                else {
                    Write-Output "Refraining from unloading module as it is defined for autoloading in the profile or was loaded before OhMyPsh started."
                }
            }
            else {
                try {
                    Write-Verbose "Attempting to remove module: $Module"
                    Remove-Module -Name $Module -Force
                }
                catch {
                    throw "Unable to remove module $($Name)"
                }
            }
        }
    }
}