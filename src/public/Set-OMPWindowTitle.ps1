Function Set-OMPWindowTitle {
    <#
    .SYNOPSIS
        Sets the Host window title.
    .DESCRIPTION
        Sets the Host window title.
    .PARAMETER Title
        Skip updating the profile

    .EXAMPLE
        PS> Set-OMPWindowTitle -Title 'My Console Rocks'

    .NOTES
        Author: Zachary Loeber
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Title
    )
    $Global:Host.UI.RawUI.WindowTitle = $Title
}