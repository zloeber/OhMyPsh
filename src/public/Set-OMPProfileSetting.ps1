Function Set-OMPProfileSetting {
    <#
    .SYNOPSIS
        Set one of the OMP settings.
    .DESCRIPTION
        Set one of the OMP settings.
    .PARAMETER Name
        Name of the setting
    .PARAMETER Value
        Value of the setting
    .EXAMPLE
        PS> Set-OMPSetting -Name 'SomeSetting' -Value 'somevalue'
    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name,
        [Parameter(Position = 1, Mandatory = $true)]
        $Value
    )
    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        Write-Verbose "Attempting to update profile setting: $Name"
    }
    Process {
        try {
            $Script:OMPProfile[$Name] = $Value
        }
        catch {
            throw "Unable to update profile setting $Name"
        }
    }
    End {
        try {
                Export-OMPProfile
        }
        catch {
            throw "Unable to update or save the profile!"
        }
    }
}