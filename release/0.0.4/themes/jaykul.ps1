<# 
    This is a theme as a token of appretiation for a fellow PowerSheller I've learned a whole
    lot from. It's one of his older prompts (slightly tweaked) but still looks pretty damn cool.
#>

function global:prompt {
    $realCommandStatus = $?
    $realLASTEXITCODE = $LASTEXITCODE

    # Output prompt string
    if ( $realCommandStatus -eq $True ) {
        $fg = (Get-OMPPromptColor)['PromptForeground']
    } else {
        $fg = (Get-OMPPromptColor)['ErrorForeground']
    }

    $bg = (Get-OMPPromptColor)['PromptBackground']

    # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
    [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
    
    try {
        Set-OMPWindowTitle -Title ("{0} - {1} ({2})" -f ("PS $($PSVersionTable.PSVersion.Major) - ${Env:UserName}@${Env:UserDomain}$(if ( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( new-object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){' (ADMIN)'})"),$pwd.Path,$pwd.Provider.Name)
    }
    catch {
        Set-OMPWindowTitle -Title ($pwd.Path)
    }
    
    # Determine what nesting level we are at (if any)
    $Nesting = "$([char]0xB7)" * $NestedPromptLevel

    # Generate PUSHD(push-location) Stack level string
    $Stack = "+" * (Get-Location -Stack).count

    # Notice: no angle brackets, makes it easy to paste my buffer to the web
    Write-Host "$([char]9556)" -NoNewLine -Foreground $fg
    Write-Host " $(if($Nesting){"$Nesting "})#$($MyInvocation.HistoryID)${Stack} " -Background $bg -Foreground $fg -NoNewLine
    if (Get-Module 'psgit') {
        Set-GitPromptSettings -BeforeForeground $fg `
                                        -BranchForeground $fg `
                                        -AheadByForeground $fg `
                                        -BehindByForeground $fg `
                                        -BeforeChangesForeground $fg `
                                        -StagedChangesForeground $fg `
                                        -SeparatorForeground $fg `
                                        -UnStagedChangesForeground $fg `
                                        -AfterChangesForeground $fg `
                                        -AfterNoChangesForeground $fg `
                                        -BeforeBackground $bg `
                                        -BranchBackground $bg `
                                        -AheadByBackground $bg `
                                        -BehindByBackground $bg `
                                        -BeforeChangesBackground $bg `
                                        -StagedChangesBackground $bg `
                                        -SeparatorBackground $bg `
                                        -UnStagedChangesBackground $bg `
                                        -AfterChangesBackground $bg `
                                        -AfterNoChangesBackground $bg `
                                        -HideZero
        Write-Host ($pwd -replace $([Regex]::Escape((Convert-Path "~"))),"~") -Background $bg -Foreground $fg -NoNewLine
        Write-VcsStatus
    }
    Write-Host ' '
    Write-Host "$([char]9562)$([char]9552)$([char]9552)$([char]9552)$([char]9557)" -Foreground $fg -NoNewLine

    $global:LASTEXITCODE = $realLASTEXITCODE
    # Hack PowerShell ISE CTP2 (requires 4 characters of output)
    if ($Host.Name -match "ISE" -and $PSVersionTable.BuildVersion -eq "6.2.8158.0") {
        return "$("$([char]8288)"*3) "
    }
    else {
        return " "
    }
}