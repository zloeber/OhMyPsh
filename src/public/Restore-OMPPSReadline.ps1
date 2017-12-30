Function Restore-OMPPSReadline {
    <#
    .SYNOPSIS
    Restores the original PSReadline colors and settings.
    .DESCRIPTION
    Restores the original PSReadline colors and settings.
    .EXAMPLE
    PS> Restore-OMPPSReadline

    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original psreadline settings and colors'
    if ($null -ne $Script:PSReadlineState) {
        $TokenKinds = @(
            'Comment',
            'Keyword',
            'String',
            'Operator',
            'Variable',
            'Command',
            'Parameter',
            'Type',
            'Number',
            'Member')
        $PSReadlineSplat = @{}
        Foreach ($ReadlineOption in ($Script:PSReadlineState | Get-Member -MemberType:Property).Name) {
            if ($ReadlineOption -match '^(.*)(ForegroundColor|BackgroundColor)$') {
                $Token = $Matches[1]
                $ParamName = $Matches[2]
                if ($TokenKinds -contains $Token) {
                    Write-Output "Restoring $ParamName for $Token to $(($Script:PSReadlineState).$ReadlineOption)"
                    $Psreadlinesplat = @{
                        TokenKind = $Token
                        $ParamName = ($Script:PSReadlineState).$ReadlineOption
                    }

                    Set-PSReadlineOption @Psreadlinesplat
                }
            }
            else {
                $PSReadlineSplat.$ReadlineOption = ($Script:PSReadlineState).$ReadlineOption
            }
        }

        Set-PSReadlineOption @PSReadlineSplat
    }

    Set-OMPConsoleColor @OriginalColors
}