$PreLoad = {
    if (-not (Get-Module 'VMware.VimAutomation.Core' -ListAvailable)) {
        throw 'vmware OhMyPsh plugin requires the vmware PowerCLI module be installed!'
    } else {
        Import-OMPModule 'VMware.VimAutomation.Core'
        Set-OMPTheme -NoProfileUpdate
    }
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