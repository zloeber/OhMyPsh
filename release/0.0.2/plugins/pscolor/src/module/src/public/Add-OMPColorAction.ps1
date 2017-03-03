Function Add-OMPColorAction {
    <#
    .SYNOPSIS
        Adds a new colorization action to take against a particular output type.
    .DESCRIPTION
        Adds a new colorization action to take against a particular output type.
    .PARAMETER Type
        Object type to colorize.
    .PARAMETER Action
        Action to take against the object type.

    .EXAMPLE
        PS> Add-OMPColorAction -Type 'System.IO.DirectoryInfo' -Action { Write-FileInfo $_ }

    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Type,
        [Parameter(Position = 1, Mandatory = $true)]
        [ScriptBlock]$Action
    )
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if ($Script:PSColorTypeMapKeys -notcontains $Type) {
        try {
            $script:PSColorTypeMap[$Type] = $Action
            $Script:PSColorTypeMapKeys = ($script:PSColorTypeMap).Keys
        }
        catch {
            throw "Unable to add PSColorType Map for $Type"
        }
    }
    else {
        Write-Output "$Type already exists as a setting. Doing nothing."
    }
}