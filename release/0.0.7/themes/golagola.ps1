function global:prompt {
    $realCommandStatus = $?
    $realLASTEXITCODE = $LASTEXITCODE

    if ( $realCommandStatus -eq $True ) {
      $EXIT= 'Green'
    }
    else {
      $EXIT= 'Red'
    }

    $Path = $pwd.ProviderPath

    Write-Host
    Write-Host "$env:USERNAME" -NoNewLine -ForegroundColor Magenta
    Write-Host " @" -NoNewLine -ForegroundColor Yellow
    Write-Host " $Path " -NoNewLine -ForegroundColor Green
    try {
      Write-OMPGitStatus
    } catch {}
    Write-Host "`n>" -NoNewLine -ForegroundColor $EXIT

    $global:LASTEXITCODE = $realLASTEXITCODE
    return " "
}