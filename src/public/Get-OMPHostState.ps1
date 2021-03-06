function Get-OMPHostState {
    <#
    .SYNOPSIS
    Returns the console host initial state when OhMyPsh is loaded.
    .DESCRIPTION
    Returns the console host initial state when OhMyPsh is loaded.
    .LINK
    https://github.com/zloeber/OhMyPsh
    .EXAMPLE
    Get-OMPHostState
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
    }
    process {
    }
    end {
        $Script:HostState
        Write-Verbose "$($FunctionName): End."
    }
}
