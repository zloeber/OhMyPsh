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
$Config = {
    <#
        psreadline configuration
    #>
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadlineOption -HistorySavePath (Get-OMPProfileSetting -Name 'PSReadlineHistoryPath')
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineOption -MaximumHistoryCount 4000
    Set-PSReadlineOption -ShowToolTips:$true

    Set-PSReadlineKeyHandler -Key "Ctrl+Delete"       -Function "KillWord"
    Set-PSReadlineKeyHandler -Key "Ctrl+Backspace"    -Function "BackwardKillWord"
    Set-PSReadlineKeyHandler -Key "Shift+Backspace"   -Function "BackwardKillWord"
    Set-PSReadlineKeyHandler -Key "UpArrow"           -Function "HistorySearchBackward"
    Set-PSReadlineKeyHandler -Key "DownArrow"         -Function "HistorySearchForward"
    Set-PSReadlineKeyHandler -Key "Tab"               -Function "MenuComplete"
    Set-PSReadlineKeyHandler -Chord 'Shift+Tab' -Function "Complete"
    Set-PSReadlineKeyHandler -Key "Ctrl+Q"            -Function "TabCompleteNext"
    Set-PSReadlineKeyHandler -Key "Ctrl+Shift+Q"      -Function "TabCompletePrevious"

    Set-PSReadlineKeyHandler -Key F1 -BriefDescription CommandHelp -LongDescription "Open the help window for the current command" -ScriptBlock {
        # Get current line(s) of input
        $ast = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$null, [ref]$null, [ref]$cursor)

        # Find the current command, use Ast to find the currently processed command, even if we are currently typing parameters for it.
        $commandAst = $ast.FindAll({
                $node = $args[0]
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.Extent.StartOffset -le $cursor -and
                $node.Extent.EndOffset -ge $cursor
            }, $true) | Select-Object -Last 1

        # If we are in the process of typing a command ...
        if ($commandAst -ne $null) {
            # Get its name
            $commandName = $commandAst.GetCommandName()
            if ($commandName -ne $null) {
                # Ensure it really is its name
                $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
                if ($command -is [System.Management.Automation.AliasInfo]) {
                    $commandName = $command.ResolvedCommandName
                }

                # Get Help
                if ($commandName -ne $null) {
                    # Call help based on preference
                    switch ($PSReadlineHelpPreference) {
                        "detail" { Start-Process powershell.exe -ArgumentList "-NoExit -Command Get-Help $commandName -Detailed" }
                        "details" { Start-Process powershell.exe -ArgumentList "-NoExit -Command Get-Help $commandName -Detailed" }
                        "example" { Start-Process powershell.exe -ArgumentList "-NoExit -Command Get-Help $commandName -Examples" }
                        "examples" { Start-Process powershell.exe -ArgumentList "-NoExit -Command Get-Help $commandName -Examples" }
                        "online" { Get-Help $commandName -Online }
                        default { Get-Help $commandName -Online }
                    }
                }
            }
        }
    }
}
$ShutDown = {
    $null = Get-History -Count (Get-OMPProfileSetting -Name 'PSReadlinePersistantHistoryCount') |
        Export-CSV "$(Get-OMPProfileSetting -Name 'PSReadlineHistoryPath').csv" -NoTypeInformation
    Set-OMPProfileSetting -Name 'PSReadlineHistoryLoaded' -Value $false
}
$Unload = {
    Remove-OMPModule -Name 'psreadline'
    Remove-OMPProfileSetting -Name 'PSReadlineHistoryLoaded'
    Remove-OMPProfileSetting -Name 'PSReadlineHistoryPath'
    Remove-OMPProfileSetting -Name 'PSReadlinePersistantHistoryCount'
}