Function Restore-OMPOriginalPSDefaultParameter {
    <#
    .SYNOPSIS
    Restores the original powershell PSDefaultParameters variable.
    .DESCRIPTION
    Restores the original powershell PSDefaultParameters variable.
    .EXAMPLE
    Restore-OMPOriginalPSParameterDefault
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original PSDefaultParameters variable'
    $Global:PSDefaultParameterValues = $Script:HostState['PSDefaultParameterValues'].Clone()
}