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

    #>
    [CmdletBinding()]
	param ()

    $Script:OMPProfileExportFile
}