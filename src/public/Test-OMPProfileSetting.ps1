Function Test-OMPProfileSetting {
    <#
    .SYNOPSIS
        Check if a profile setting exists.
    .DESCRIPTION
        Check if a profile setting exists.
    .PARAMETER Name
        Name of the setting.
    .EXAMPLE
        PS> Test-OMPProfileSetting -Name 'SomeSetting'

        If SomeSetting exists then $true is returned. Otherwise $false is returned.
    .NOTES
        Author: Zachary Loeber
    .LINK
        https://github.com/zloeber/ohmypsh
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [String]$Name
    )
    Process {
        if (($Script:OMPProfile).Keys -contains $Name ) {
            $true
        }
        else {
            $false
        }
    }
}
