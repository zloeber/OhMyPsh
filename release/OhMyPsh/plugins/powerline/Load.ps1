$PreLoad = {
    Import-OMPModule 'Powerline'
}
$PostLoad = {}
$Config = {}
$Shutdown = {}
$Unload = {
    Remove-OMPModule -Name 'powerline' -PluginSafe
}