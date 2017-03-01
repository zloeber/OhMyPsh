Function Get-OMPPSColor {
    <#
    .SYNOPSIS
        Display the PSColor settings.
    .DESCRIPTION
        Display the PSColor settings.
    .EXAMPLE
        PS> Get-OMPPSColor

        Shows the PSColor settings
    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param ()
    
    $Script:PSColor
}