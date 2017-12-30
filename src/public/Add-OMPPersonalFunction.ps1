Function Add-OMPPersonalFunction {
    <#
    .SYNOPSIS
        Adds a function to be autoloaded into your session when OMP starts up.
    .DESCRIPTION
        Adds a function to be autoloaded into your session when OMP starts up.
    .PARAMETER Path
        Name of the script.
    .PARAMETER Recurse
        Add every script in the directory.
    .PARAMETER NoProfileUpdate
        Skip updating the profile.
    .EXAMPLE
        PS> Add-OMPPersonalFunction -Path 'C:\users\jdoe\scripts\myscript.ps1'

        Adds 'C:\users\jdoe\scripts\myscript.ps1' to the list of functions that will be loaded
        with OhMyPsh for this user.
    .NOTES
        Author: Zachary Loeber
    .LINK
        https://github.com/zloeber/ohmypsh
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path,
        [Parameter(Position = 1)]
        [switch]$Recurse,
        [Parameter(Position = 2)]
        [switch]$NoProfileUpdate
    )
    $PathsAdded = $false
    if (Test-Path $Path) {
        if ($Recurse) {
            $Paths = @((Get-ChildItem -Path $Path -File -Filter '*.ps1').FullName)
        }
        else {
            $Paths = $($Path)
        }
        Foreach ($ScriptPath in $Paths) {
            Write-Verbose "Checking if the following is a valid candidate for being added: $ScriptPath"
            if ($Script:OMPProfile['PersonalFunctions'] -notcontains $ScriptPath){
                try {
                    Invoke-OMPPersonalFunction -Path $ScriptPath -Tag 'personalfunction'
                    $PathsAdded = $true
                    $Script:OMPProfile['PersonalFunctions'] += $ScriptPath
                }
                catch {
                    Write-Warning "Unable to load $ScriptPath"
                }
            }
        }
    }
    try {
        if ((-not $NoProfileUpdate) -and $PathsAdded) {
            Write-Verbose "Profile being updated"
            Export-OMPProfile
        }
    }
    catch {
        throw "Unable to add module $($Name)"
    }
}