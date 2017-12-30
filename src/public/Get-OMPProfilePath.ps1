Function Get-OMPProfilePath {
    <#
    .SYNOPSIS
    Retrieve the current OhMyPsh profile path.
    .DESCRIPTION
    Retrieve the current OhMyPsh profile path.
    .EXAMPLE
    PS> Get-OMPProfilePath
    Shows the current profile path.
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param ()

    $Script:OMPProfileExportFile
}