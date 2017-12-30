$PreLoad = {
    # Note, we skip using Import-OMPModule as the required module is packaged
    # with this plugin.
    Import-Module (Join-Path $PluginPath 'nlog\NLogModule\NLogModule.psm1') -Global -Force
}
$PostLoad = {
    Register-NLog -FileName (Join-Path $ENV:TEMP 'ModuleBuild.log') -LoggerName 'OhMyPsh'
    Write-Output "Loaded the nlog plugin. The logged output can be found in $(Join-Path $ENV:TEMP 'ModuleBuild.log')"
}
$Config = {}
$Shutdown = {}
$Unload = {
    UnRegister-NLog
    Remove-OMPModule -Name 'NLogModule' -PluginSafe
}