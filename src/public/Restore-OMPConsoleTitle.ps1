Function Restore-OMPConsoleTitle {
    <#
    .SYNOPSIS
    Restores the original console colors and title.
    .DESCRIPTION
    Restores the original console colors and title.
    .EXAMPLE
    PS> Restore-OMPOriginalConsole

    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original console title'
    $Global:Host.UI.RawUI.WindowTitle = $Script:HostState['Title']
}