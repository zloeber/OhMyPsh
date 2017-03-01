Function Add-OMPProfileSetting {
    <#
    .SYNOPSIS
        Adds a new setting to the user profile settings if they do not already exist. Afterwards the profile is automatically exported and saved.
    .DESCRIPTION
        Adds a new setting to the user profile settings if they do not already exist. Afterwards the profile is automatically exported and saved.
    .PARAMETER Name
        Name of the setting
    .PARAMETER Value   
        Value of the setting.
    .PARAMETER NoProfileUpdate
        Skip updating the profile
    .EXAMPLE
        PS> Add-OMPProfileSetting -Name 'CustomSetting' -Value 'MySetting'

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
        $Value,
        [Parameter(Position = 2)]
        [switch]$NoProfileUpdate
    )
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $ExistingSettings = @(($Script:OMPProfile).Keys)
    Write-Verbose "Existing settings: $($ExistingSettings -join ', ')"
    if ($ExistingSettings -notcontains $Name) {
        try {
            $Script:OMPProfile[$Name] = $Value
        }
        catch {
            Write-Error "Unable to add profile setting $Name"
        }

        if (-not $NoProfileUpdate) {
            try {
                Export-OMPProfile
            }
            catch {
                throw "Unable to update or save the profile!"
            }
        }
    }
    else {
        Write-Output "$Name already exists as a setting. Doing nothing."
    }
}