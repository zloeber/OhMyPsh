Function Remove-OMPColorAction {
    <#
    .SYNOPSIS
        Removes a colorization action.
    .DESCRIPTION
        Removes a colorization action.
    .PARAMETER Name
        Type name to remove

    .EXAMPLE
        PS> Remove-OMPColorAction -Name 'Custom.Type'

    .NOTES
        Author: Zachary Loeber


        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name
    )
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if ($Script:PSColorTypeMapKeys -contains $Name) {
        ($Script:PSColorTypeMap).Remove($Name)
        $Script:PSColorTypeMapKeys = ($script:PSColorTypeMap).Keys
    }
    else {
        Write-Error "Typename of $Name does not exist!"
    }
}