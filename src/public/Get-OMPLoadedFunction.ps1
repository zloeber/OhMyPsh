function Get-OMPLoadedFunction {
    <#
    .Synopsis
    Shows OhMyPsh sourced functions that have been loaded to this session.
    .DESCRIPTION
    Shows OhMyPsh sourced functions that have been loaded to this session.
    .PARAMETER Name
    The function name. If nothing is passed all sourced functions are listed.

    .EXAMPLE
    Get-OMPLoadedFunction

    Shows all OhMyPsh plugin functions that have been exported to this session.
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Name = '*'
    )
    Process {
        Get-ChildItem -Path "Function:\$Name" -Recurse | Where-Object { $null -ne $_.ohmypsh } | Select Name,ohmypsh
    }
}