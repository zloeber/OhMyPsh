$PreLoad = {
    if (-not (Test-OMPProfileSetting -Name 'PSReadlineHistoryPath')) {
        try {
            Add-OMPProfileSetting -Name 'PSReadlineHistoryPath' -Value (Join-Path (Split-Path $Profile) '.powershell.history')
        }
        catch {
            throw 'Unable to add psreadline profile settting PSReadlineHistoryPath!'
        }

        if (Test-Path (Get-OMPProfileSetting -Name 'PSReadlineHistoryPath')) {
            Write-Output "NOTE: PSReadline history file already exists: $(Join-Path (Split-Path $Profile) '.powershell.history')"
        }
    }
    if (-not (Test-OMPProfileSetting -Name 'PSReadlineHistoryLoaded')) {
        try {
            Add-OMPProfileSetting -Name 'PSReadlineHistoryLoaded' -Value $false
        }
        catch {
            throw 'Unable to add psreadline profile settting PSReadlineHistoryLoaded!'
        }
    }
    if ((Test-Path "$(Get-OMPProfileSetting -Name 'PSReadlineHistoryPath').csv") -and 
         (-not (Get-OMPProfileSetting -Name 'PSReadlineHistoryLoaded'))) {
        $null = Import-CSV "$(Get-OMPProfileSetting -Name 'PSReadlineHistoryPath').csv" | Add-History
        Set-OMPProfileSetting -Name 'PSReadlineHistoryLoaded' -Value $true
    }
    if (-not (Test-OMPProfileSetting -Name 'PSReadlinePersistantHistoryCount')) {
        try {
            Add-OMPProfileSetting -Name 'PSReadlinePersistantHistoryCount' -Value 50
        }
        catch {
            throw 'Unable to add psreadline profile settting PSReadlinePersistantHistoryCount!'
        }
    }
    Import-OMPModule 'PSReadline'
}

$PostLoad = {}

$ShutDown = {
    $null = Get-History -Count (Get-OMPProfileSetting -Name 'PSReadlinePersistantHistoryCount') | 
        Export-CSV "$(Get-OMPProfileSetting -Name 'PSReadlineHistoryPath').csv" -NoTypeInformation
    Set-OMPProfileSetting -Name 'PSReadlineHistoryLoaded' -Value $false
}