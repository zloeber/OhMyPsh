Function Restore-OMPOriginalPSDefaultParameter {
    <#
    .SYNOPSIS
        Restores the original powershell PSDefaultParameters variable.
    .DESCRIPTION
        Restores the original powershell PSDefaultParameters variable.
    .EXAMPLE
        PS> Restore-OMPOriginalPSParameterDefault

    .NOTES
        Author: Zachary Loeber


        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param ()
    Write-Output 'Restoring original PSDefaultParameters variable'
    $Global:PSDefaultParameterValues = $Script:HostState['PSDefaultParameterValues'].Clone()

}