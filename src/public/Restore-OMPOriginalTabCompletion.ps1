Function Restore-OMPOriginalTabCompletion {
    <#
    .SYNOPSIS
        Restores the original powershell TabCompletion and TabCompletion2 functions.
    .DESCRIPTION
        Restores the original powershell TabCompletion and TabCompletion2 functions.
    .EXAMPLE
        PS> Restore-OMPOriginalTabCompletion

    .NOTES
        Author: Zachary Loeber


        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param ()
#    if ($null -ne $Script:OldTabExpansion) {
        Write-Output 'Restoring original TabExpansion function'
        Set-Item function:\TabExpansion $Script:HostState['TabExpansion']
#    }
#    if ($null -ne $Script:OldTabExpansion2) {
        Write-Output 'Restoring original TabExpansion2 function'
        Set-Item function:\TabExpansion2 $Script:HostState['TabExpansion2']
#    }
}