# Very basic prompt without git integration but with some conemu detection. Fast and stable.
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host
    Write-Host ($pwd.ProviderPath -replace $([Regex]::Escape((Convert-Path "~"))),"~") -NoNewLine
    $global:LASTEXITCODE = $realLASTEXITCODE
    Write-Host "`nλ" -NoNewLine -ForegroundColor "DarkGray"
    $out = " "

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