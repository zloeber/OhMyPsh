Function Import-OMPProfile {
    <#
    .SYNOPSIS
        Loads a user profile.
    .DESCRIPTION
        Loads a user profile.
    .PARAMETER Path
        Path to the user module profile settings.
    .EXAMPLE
        PS> Import-OMPProfile -Path C:\temp\.OhMyPsh.profile.json

        Loads the profile from C:\temp\.OhMyPsh.profile.json into the module settings
    .NOTES
        Author: Zachary Loeber
    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [string]$Path = $Script:OMPProfileExportFile
    )

    try {
        $LoadedProfile = Get-Content $Path | ConvertFrom-Json
    }
    catch {
        throw "Unable to load $Path"
    }

    $ProfileSettings = ($LoadedProfile | Get-Member -Type 'NoteProperty').Name
    ForEach ($Key in $ProfileSettings) {
        if (@($Script:OMPProfile.Keys) -contains $Key) {
            Write-Verbose "Updating profile setting '$key' from $Path"
            $Script:OMPProfile[$Key] = $LoadedProfile.$Key
        }
        else {
            Write-Verbose "Adding profile setting '$key' from $Path"
            ($Script:OMPProfile).$Key = $LoadedProfile.$Key
        }
    }
    $MissingSettings = @($Script:OMPProfile.Keys | Where {$ProfileSettings -notcontains $_})
    if ($MissingSettings.Count -gt 0) {
        Write-Verbose "There were $($MissingSettings.Count) settings missing from the saved profile. Re-exporting to bring profile up to date."
        try {
            Export-OMPProfile -Path $Script:OMPProfileExportFile
        }
        catch {
            throw "Unable to export profile to $($Script:OMPProfileExportFile)"
        }
    }
}
