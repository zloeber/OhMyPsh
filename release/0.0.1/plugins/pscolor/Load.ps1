$PreLoad = {
    Import-Module (Join-Path $PluginPath 'pscolor\src\module\pscolor.psm1') -Global -Force
}
$PostLoad = {}
$Config = {}
$Shutdown = {}