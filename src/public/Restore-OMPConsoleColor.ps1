Function Restore-OMPConsoleColor {
    <#
    .SYNOPSIS
    Restores the original console colors.
    .DESCRIPTION
    Restores the original console colors.
    .EXAMPLE
    PS> Restore-OMPConsoleColor

    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original console colors (this does not include psreadline configurations)'
    $OriginalColors = $Script:HostState['colors']

    Set-OMPConsoleColor @OriginalColors
}