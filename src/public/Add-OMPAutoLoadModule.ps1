Function Add-OMPAutoLoadModule {
    <#
    .SYNOPSIS
        Adds a module to be autoloaded when OMP starts up.
    .DESCRIPTION
        Adds a module to be autoloaded when OMP starts up.
    .PARAMETER Name
        Name of the module
    .PARAMETER NoProfileUpdate
        Skip updating the profile
    .EXAMPLE
        PS> Add-OMPAutoLoadModule -Name 'posh-git'

        Adds posh-git to the list of modules that will be loaded with OhMyPsh for this user.

    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name,
        [Parameter(Position = 1)]
        [switch]$NoProfileUpdate
    )
    try {
        Import-OMPModule -Name $Name
        $Script:OMPProfile['AutoLoadModule'] = @($Script:OMPProfile['AutoLoadModule'] + $Name | Sort-Object -Unique)
        if (-not $NoProfileUpdate) {
            Export-OMPProfile
        }
    }
    catch {
        throw "Unable to add module $($Name)"
    }
}