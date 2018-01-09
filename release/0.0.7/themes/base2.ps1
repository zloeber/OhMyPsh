# A more complete but still rather basic prompt with posh-git checking, admin elevation differentiation, and conemu checks.

$Global:_AmIElevated = Test-OMPIsElevated
function Global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host

    # Reset color, which can be messed up by Enable-GitColors or other processes
    $Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor

    if ($Global:_AmIElevated) {
        Write-Host "(Elevated) " -NoNewline -ForegroundColor White
    }

    Write-Host "$($ENV:USERNAME)@" -NoNewline -ForegroundColor DarkYellow
    Write-Host "$($ENV:COMPUTERNAME)" -NoNewline -ForegroundColor Magenta

    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host ($($pwd.ProviderPath) -replace [regex]::escape($($env:USERPROFILE)), "~") -NoNewline -ForegroundColor Blue
    Write-Host ' : ' -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkMagenta
    Write-Host ' ' -NoNewline

    $global:LASTEXITCODE = $realLASTEXITCODE

    # Posh-git integration
    try {
        Write-OMPGitStatus
    }
    catch {}

    Write-Host ''
    $out = '> '
    # Simple check for ConEmu existance and ANSI emulation enabled
    if ($env:ConEmuANSI -eq "ON") {
        # Let ConEmu know when the prompt ends, to select typed
        # command properly with "Shift+Home", to change cursor
        # position in the prompt by simple mouse click, etc.
        $out += "$([char]27)]9;12$([char]7)"

        # And current working directory (FileSystem)
        # ConEmu may show full path or just current folder name
        # in the Tab label (check Tab templates)
        # Also this knowledge is crucial to process hyperlinks clicks
        # on files in the output from compilers and source control
        # systems (git, hg, ...)
        if ($loc.Provider.Name -eq "FileSystem") {
            $out += "$([char]27)]9;9;`"$($pwd.Path)`"$([char]7)"
        }
    }

    return $out
}