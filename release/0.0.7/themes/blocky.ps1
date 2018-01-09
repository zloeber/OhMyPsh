# Super basic theme
function global:prompt {
    $realCommandStatus = $?
    $realLASTEXITCODE = $LASTEXITCODE
    $Path = $pwd.ProviderPath
    Write-Host
    Write-Host " $Path " -NoNewLine -ForegroundColor Black -BackgroundColor White

    # Posh-git integration
    try {
        Write-VcsStatus
    } catch {}

    if ( $realCommandStatus -eq $True ) {
      $BG_EXIT="Green"
    }
    else {
      $BG_EXIT="Red"
    }
    $global:LASTEXITCODE = $realLASTEXITCODE
    Write-Host "`n > " -NoNewLine -ForegroundColor White -BackgroundColor $BG_EXIT
    return " "
}