Function Restore-OMPOriginalAlias {
    <#
    .SYNOPSIS
        Restores original aliases that are backed up when this module initially loads.
    .DESCRIPTION
        Restores original aliases that are backed up when this module initially loads.

    .EXAMPLE
        PS> Restore-OMPOriginalAlias

    .NOTES
        Author: Zachary Loeber


        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param ()
    # I cannot figure out a way to import these automatically back into the users session when the module unloads
    # so for now tell the user how to do so themselves if so desired.
    $Path = $Script:HostState['Aliases']
    if ((Test-Path $Path)) {
        Write-Output ''
        Write-Output "Original aliases stored in $Path"
        Write-Output "To restore these into your session run the following: "
        Write-Output ''
        Write-Output ". $Path"
        Write-Output ''
    }
}