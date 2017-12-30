Function Restore-OMPConsolePrompt {
    <#
    .SYNOPSIS
    Restores the original powershell prompt function.
    .DESCRIPTION
    Restores the original powershell prompt function.
    .EXAMPLE
    PS> Restore-OMPConsolePrompt
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param ()
    #if ($null -ne $Script:OldPrompt) {
        Write-Verbose 'Restoring original Prompt function'
        Set-Item Function:\prompt $Script:HostState['Prompt']
    #}
}