$PreLoad = {
    $Global:OMPConsoleHasANSI = Test-OMPConsoleHasANSI
    if ($OMPConsoleHasANSI) {
        Import-OMPModule Pansies
    }
}
$PostLoad = {
    if ($Host.Name -eq 'ConsoleHost') {
        Write-SessionBannerToHost
    }
}
$Config = {}
$Shutdown = {}
$Unload = {}