Function Get-OMPColorAction {
    <#
    .SYNOPSIS
        Get one or all of the OMP color actions.
    .DESCRIPTION
        Get one or all of the OMP color actions.
    .PARAMETER Name
        Name of the setting
    .EXAMPLE
        PS> Get-OMPColorAction -Name 'SomeTypeName'

        Shows the action assigned to SomeTypeName
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
        if ([string]::IsNullOrEmpty($Name)) {
            $Script:PSColorTypeMap
        }
        else {
            if ($Script:PSColorTypeMapKeys -contains $Name) {
                $Script:PSColorTypeMap[$Name]
            }
            else {
                Write-Error "Typename of $Name does not exist!"
            }
        }
    }
}