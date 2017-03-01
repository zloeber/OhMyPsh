Function Remove-OMPProfileSetting {
    <#
    .SYNOPSIS
        Removes a custom profile setting that is not one of the core settings. Afterwards the profile is automatically exported and saved.
    .DESCRIPTION
        Removes a custom profile setting that is not one of the core settings. Afterwards the profile is automatically exported and saved.
    .PARAMETER Name
        Name of the setting
    .PARAMETER NoProfileUpdate
        Skip updating the profile
    .EXAMPLE
        PS> Remove-OMPProfileSetting -Name 'CustomSetting'

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
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $ExistingSettings = @(($Script:OMPProfile).Keys)

    if (($ExistingSettings -contains $Name) -and ($Script:OMPProfileCoreSettings -notcontains $Name)) {
        try {
            ($Script:OMPProfile).Remove($Name)
        }
        catch {
            Write-Error "Unable to remove profile setting $Name"
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
        Write-Output "$Name either doesn't exist or is a core profile property"
    }
}