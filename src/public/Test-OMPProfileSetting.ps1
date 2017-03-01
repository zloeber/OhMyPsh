Function Test-OMPProfileSetting {
    <#
    .SYNOPSIS
        Check if a profile setting exists.
    .DESCRIPTION
        Check if a profile setting exists.
    .PARAMETER Name
        Name of the setting.
    .EXAMPLE
        PS> Test-OMPSetting -Name 'SomeSetting'

        If SomeSetting exists then $true is returned. Otherwise $false is returned.
    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [String]$Name
    )
    Process {
        if (($Script:OMPProfile).Keys -contains $_ ) {
            $true
        }
        else {
            $false
        }
    }
}
