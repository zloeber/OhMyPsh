function Get-OMPPowerShellProfileState {
    <#
    .SYNOPSIS
    Retrieves all Powershell profiles for the exisisting session, if they exist, and the order of operation they are processed.
    .DESCRIPTION
    Retrieves all Powershell profiles for the exisisting session, if they exist, and the order of operation they are processed.
    .LINK
    https://github.com/zloeber/OhMyPsh
    .EXAMPLE
    Get-OMPPowerShellProfileState
    .NOTES
    Author: Zachary Loeber
    #>

    [CmdletBinding()]
    param(
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."

        $ProfileTypes = @('AllUsersAllHosts','AllUsersCurrentHost','CurrentUserAllHosts','CurrentUserCurrentHost')
    }
    end {
        $order = 0
        Foreach ($PType in $Profiletypes) {
            $order++
            New-Object -TypeName psobject -Property @{
                Name = $PType
                Exists = if (test-path $PROFILE.$Ptype) {$true} else {$false}
                Path = $PROFILE.$Ptype
                Order = $order
            } | Select Order, Name, Exists, Path
        }
        Write-Verbose "$($FunctionName): End."
    }
}
