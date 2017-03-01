Function Export-OMPProfile {
    <#
    .SYNOPSIS
        Saves a user profile.
    .DESCRIPTION
        Saves a user profile.
    .PARAMETER Path
        Path to the user module profile settings.
    .EXAMPLE
        PS> Export-OMPProfile -Path C:\temp\.OhMyPsh.profile.json

        Saves the profile settings to C:\temp\.OhMyPsh.profile.json into the module settings
    .NOTES
        Author: Zachary Loeber

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
