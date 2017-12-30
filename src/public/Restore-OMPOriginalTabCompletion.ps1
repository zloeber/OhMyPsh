Function Restore-OMPOriginalTabCompletion {
    <#
    .SYNOPSIS
    Restores the original powershell TabCompletion and TabCompletion2 functions.
    .DESCRIPTION
    Restores the original powershell TabCompletion and TabCompletion2 functions.
    .EXAMPLE
    Restore-OMPOriginalTabCompletion
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original TabExpansion function'
    Set-Item function:\TabExpansion $Script:HostState['TabExpansion']

    Write-Verbose 'Restoring original TabExpansion2 function'
    Set-Item function:\TabExpansion2 $Script:HostState['TabExpansion2']
}