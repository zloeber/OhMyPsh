Remove-Module ohmypsh -ErrorAction:SilentlyContinue

if (Test-Path $Global:_OMPProfilePath) {
    Write-Output "Removing OhMyPsh profile that this build automatically generated.."
    try {
        Remove-Item -Path $Global:_OMPProfilePath -Force
    }
    catch {
        throw
    }
}

if (Test-Path $Global:_OMPProfileBackupPath) {
    Write-Output "Found backup OhMyPsh profile, attempting to restore to $($Global:_OMPProfilePath)"
    try {
        Move-Item -Path $Global:_OMPProfileBackupPath -Destination $Global:_OMPProfilePath
    }
    catch {
        throw
    }
}

if ($Global:_OMPModuleLoaded) {
    Write-Output 'OhMyPsh attempting to reload...'
    Import-Module OhMyPsh
}

Remove-Variable -Name '_OMPProfilePath' -Force -ErrorAction:SilentlyContinue
Remove-Variable -Name '_OMPProfileBackupPath' -Force -ErrorAction:SilentlyContinue
Remove-Variable -Name '_OMPModuleLoaded' -Force -ErrorAction:SilentlyContinue