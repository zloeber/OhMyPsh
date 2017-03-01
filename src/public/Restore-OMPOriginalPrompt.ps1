Function Restore-OMPOriginalPrompt {
    <#
    .SYNOPSIS
        Restores the original powershell prompt function.
    .DESCRIPTION
        Restores the original powershell prompt function.
    .EXAMPLE
        PS> Restore-OMPOriginalPrompt

    .NOTES
        Author: Zachary Loeber


        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param ()
    #if ($null -ne $Script:OldPrompt) {
        Write-Output 'Restoring original Prompt function'
        Set-Item Function:\prompt $Script:HostState['Prompt']
    #}
}