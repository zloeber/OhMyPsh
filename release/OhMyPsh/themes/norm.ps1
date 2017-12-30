<# Based on norm zsh theme. Check it (https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/norm.zsh-theme) #>

function global:prompt {
    $realCommandStatus = $?
    $realLASTEXITCODE = $LASTEXITCODE
    $lambda = [char]::ConvertFromUtf32(955)
    $forwardArrow = [char]::ConvertFromUtf32(8594)

    if ($realCommandStatus) {
      $EXIT="Yellow"
    }
    else {
      $EXIT="Red"
    }
    $CurrentDirectory = $pwd.ProviderPath -replace [regex]::escape($($env:USERPROFILE)), "~"
    $Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor

    Write-Host
    Write-Host "$lambda $env:USERNAME " -ForegroundColor Yellow -NoNewline
    Write-Host "$CurrentDirectory" -NoNewLine -ForegroundColor $EXIT

    Write-OMPGitStatus

    $out = " $forwardArrow"
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
    $global:LASTEXITCODE = $realLASTEXITCODE
    return $out
}