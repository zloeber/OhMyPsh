function Set-OMPGitOutput {
    <#
    .SYNOPSIS
    Sets the default git output module. This can be used to flip between posh-git and psgit modules.
    .DESCRIPTION
    Sets the default git output module. This can be used to flip between posh-git and psgit modules. This is important for customized prompt output as well as in general for managing git repos on your system. The default is just to use some basic scripts with this module. Otherwise this can be posh-git or psgit (named so after the modules that get loaded). Write-OMPGitStatus uses this setting directly to determine how to spit out VCS information to the prompt.
    .PARAMETER Name
    Name of the git output module to use. psgit, posh-git, or script. Default is script and no modules are used for writing version control to the prompt.
    .LINK
    https://github.com/zloeber/OhMyPsh
    .EXAMPLE
    Set-OMPGitOutput -Name 'psgit'
    .NOTES
    Author: Zachary Loeber
    #>

    [CmdletBinding()]
	param (
        [Parameter(Position = 0)]
        [ValidateSet('psgit','posh-git','script')]
        [string]$Name = 'script'
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    end {
        switch ($Name) {
            'psgit' {
                Write-Verbose "$($FunctionName): Setting to psgit, attempting to unload posh-git if loaded."
                Remove-OMPAutoLoadModule 'posh-git' -ErrorAction:SilentlyContinue
                if (get-module 'posh-git') { Remove-Module 'posh-git' -ErrorAction:SilentlyContinue }

                try {
                    Import-OMPModule 'psgit'
                    Add-OMPAutoLoadModule 'psgit'
                    Set-OMPProfileSetting -Name:OMPGitOutput -Value:$Name
                }
                catch {
                    Write-Warning "$($FunctionName): Unable to load psgit module! Leaving current OMP git output setting in place."
                }
            }
            'posh-git' {
                Write-Verbose "$($FunctionName): Setting to posh-git, attempting to unload psgit if loaded."
                Remove-OMPAutoLoadModule 'psgit' -ErrorAction:SilentlyContinue
                if (get-module 'psgit') { Remove-Module 'psgit' -ErrorAction:SilentlyContinue }

                try {
                    Import-OMPModule 'posh-git'
                    Add-OMPAutoLoadModule 'posh-git'
                    Set-OMPProfileSetting -Name:OMPGitOutput -Value:$Name
                }
                catch {
                    Write-Warning "$(FunctionName): Unable to load posh-git module! Leaving current OMP git output setting in place."
                }
            }
            Default {
                Write-Verbose "$($FunctionName): Setting to script, leaving git modules as they are"
                Remove-OMPAutoLoadModule 'psgit'
                Remove-OMPAutoLoadModule 'posh-git'
                if (get-module 'psgit') { Remove-Module 'psgit' -ErrorAction:SilentlyContinue }
                if (get-module 'posh-git') { Remove-Module 'posh-git' -ErrorAction:SilentlyContinue }
                Set-OMPProfileSetting -Name:OMPGitOutput -Value:$Name
            }
        }

        Write-Verbose "$($FunctionName): End."
    }
}
