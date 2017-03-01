$Unload = {
    Remove-OMPModule -Name 'psreadline'
    Remove-OMPProfileSetting -Name 'PSReadlineHistoryLoaded'
    Remove-OMPProfileSetting -Name 'PSReadlineHistoryPath'
    Remove-OMPProfileSetting -Name 'PSReadlinePersistantHistoryCount'
}