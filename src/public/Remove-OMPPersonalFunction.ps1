Function Remove-OMPPersonalFunction {
    <#
    .SYNOPSIS
        Removes a loaded personal function path from the profile.
    .DESCRIPTION
        Removes a loaded personal function path from the profile.
    .PARAMETER Path
        Path to the personal function.
    .PARAMETER NoProfileUpdate
        Skip updating the profile
    .EXAMPLE
        PS> Remove-OMPPersonalFunction -Name 'C:\temp\Upgrade-System.ps1'

        Removes posh-git from the list of modules that will be loaded when OhMyPsh starts.

    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path,
        [Parameter(Position = 1)]
        [switch]$NoProfileUpdate
    )
    try {
        $Script:OMPProfile['PersonalFunctions'] = @($Script:OMPProfile['PersonalFunctions'] | Where-Object {$_ -ne $Path} | Sort-Object -Unique)
        if (-not $NoProfileUpdate) {
            Export-OMPProfile
        }
    }
    catch {
        throw "Unable to remove personal function path: $Path"
    }
}