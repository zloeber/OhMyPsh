Function Export-OMPProfile {
    <#
    .SYNOPSIS
    Saves the current OhMyPsh profile.
    .DESCRIPTION
    Saves the current OhMyPsh profile.
    .PARAMETER Path
    Path to the user module profile settings.
    .EXAMPLE
    PS> Export-OMPProfile -Path C:\temp\.OhMyPsh.profile.json

    Saves the profile settings to C:\temp\.OhMyPsh.profile.json into the module settings
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://github.com/zloeber/ohmypsh
    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [string]$Path = $Script:OMPProfileExportFile
    )

    try {
        $Script:OMPProfile | ConvertTo-Json | Out-File $Path -Encoding:utf8 -Force
    }
    catch {
        throw "Unable to save $Path"
    }
}
