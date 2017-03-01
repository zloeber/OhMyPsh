$PreLoad = {
    if (-not (Get-Module 'VMware.VimAutomation.Core' -ListAvailable)) {
        throw 'vmware OhMyPsh plugin requires the vmware PowerCLI module be installed!'
    } else {
        Import-OMPModule 'VMware.VimAutomation.Core'
        Set-OMPTheme -NoProfileUpdate
    }
}
$PostLoad = {}
$Shutdown = {
    Remove-OMPModule -Name 'VMware*' -PluginSafe
}