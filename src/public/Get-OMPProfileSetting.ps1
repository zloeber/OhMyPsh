Function Get-OMPProfileSetting {
    <#
    .SYNOPSIS
    Get one or all of the OMP settings.
    .DESCRIPTION
    Get one or all of the OMP settings.
    .PARAMETER Name
    Name of the setting
    .EXAMPLE
    PS> Get-OMPSetting -Name 'SomeSetting'

    Shows the value of SomeSetting
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateScript({
            (($Script:OMPProfile).Keys -contains $_ ) -or ([string]::IsNullOrEmpty($_))
        })]
        [String]$Name
    )
    process {
        if ([string]::IsNullOrEmpty($Name)) {
            $Script:OMPProfile
        }
        else {
            $Script:OMPProfile[$Name]
        }
    }
}