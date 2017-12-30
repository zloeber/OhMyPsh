$PreLoad = {
    Import-OMPModule 'vmware.powercli'
    Set-OMPTheme
}
$PostLoad = {}
$Config = {}
$Shutdown = {
    Remove-OMPModule -Name 'VMware*' -PluginSafe
}
$Unload = {
   # Remove-Module Initialize-VMware_VimAutomation_Cis -Force
    Remove-OMPModule -Name 'VMware*' -PluginSafe
}