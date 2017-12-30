if (Get-Module OhMyPsh) {
    Write-Output "OhMyPsh is currently loaded, removing to prepare for this build"
    $Global:_OMPModuleLoaded = $true
    Remove-Item $Global:_OMPProfileBackupPath -Force -ErrorAction:SilentlyContinue
}

$Global:_OMPProfilePath = Join-Path (Split-Path $Profile) '.OhMyPsh.config.json'
$Global:_OMPProfileBackupPath = Join-Path (Split-Path $Profile) '.OhMyPsh.config.json.bak'
Remove-Module ohmypsh -ErrorAction:SilentlyContinue
if (Test-Path $Global:_OMPProfilePath) {
    try {
        Move-Item -Path $Global:_OMPProfilePath -Destination $Global:_OMPProfileBackupPath
    }
    catch {
        throw
    }
}

# Clean EZOut Templates
Remove-Item -Path 'plugins\ezout\formats\*.format.ps1xml' -Force