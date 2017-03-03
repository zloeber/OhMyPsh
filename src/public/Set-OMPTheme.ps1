Function Set-OMPTheme {
    <#
    .SYNOPSIS
        Sets the theme.
    .DESCRIPTION
        Sets the theme.
    .PARAMETER Name
        Name of the Theme
    .PARAMETER NoProfileUpdate
        Skip updating the profile
    .EXAMPLE
        PS> Set-OMPTheme -Name 'base'
    .NOTES
        Author: Zachary Loeber
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0)]
        [String]$Name = $Script:OMPProfile['Theme'],
        [Parameter(Position = 1)]
        [switch]$NoProfileUpdate
    )
    $Verbosity = if ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent) {' -Verbose'} else {''}
    if ([string]::IsNullOrEmpty($Name)) {
        Write-Output "No theme specified, restoring the original PowerShell prompt"
        Restore-OMPOriginalPrompt
        return
    }
    $ThemeScriptPath = (Join-Path $Script:ModulePath "themes\$Name.ps1")
    if (Test-Path $ThemeScriptPath) {
        Write-Verbose "Loading theme file: $ThemeScriptPath"
        $script = (Get-Content $ThemeScriptPath -Raw)
        try {
            $sb = [Scriptblock]::create(".{$script}")
            Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
            if (-not ([string]::IsNullOrEmpty($errmsg))) {
                throw "Unable to load theme file $ThemeScriptPath"
            }
            else {
                Set-OMPProfileSetting -Name 'Theme' -Value $Name
            }
        }
        catch {
            throw "Unable to load theme file $ThemeScriptPath"
        }
        if (-not $NoProfileUpdate) {
            $Script:OMPProfile['Theme'] = $Name
        }
    }
    else {
        Throw "Theme with the name $Name was not found!"
    }
}