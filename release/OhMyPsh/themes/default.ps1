# A plain old default prompt with some framework in place to make your own snazzier version.
# There is no git integration but it does include some conemu detection. Fast and stable.
function global:prompt {
    $realCommandStatus = $?
    $realLASTEXITCODE = $LASTEXITCODE

    # Customize any of these if you like
    $DefaultPromptPrefix = 'PS '
    $PromptSuffix = '> ' #[char]::ConvertFromUtf32(8594)
    $LastCommandSuccessForeground = $Host.UI.RawUI.ForegroundColor
    $LastCommandErrorForeground = if ($null -ne $host.PrivateData.ErrorForegroundColor) {$host.PrivateData.ErrorForegroundColor} else {'Red'}

    # If stopped in the debugger, the prompt needs to indicate that in some fashion
    $hasInBreakpoint = [runspace]::DefaultRunspace.Debugger | Get-Member -Name InBreakpoint -MemberType property
    $debugMode = (Test-Path Variable:/PSDebugContext) -or ($hasInBreakpoint -and [runspace]::DefaultRunspace.Debugger.InBreakpoint)
    $PromptPrefix = if ($debugMode) { 'DEBUG ' } else { $DefaultPromptPrefix }

    # Finally, pull our current location
    $loc = Get-Location

    # File system paths are case-sensitive on Linux and case-insensitive on Windows and macOS
    if (($PSVersionTable.PSVersion.Major -ge 6) -and $IsLinux) {
        $stringComparison = [System.StringComparison]::Ordinal
    }
    else {
        $stringComparison = [System.StringComparison]::OrdinalIgnoreCase
    }

    # Based on provider we can shorten or do other things to our output
    switch ($loc.Provider.Name) {
        'FileSystem' {
            # Shorten the file path a bit if possible
            # Abbreviate path by replacing beginning of path with ~ *iff* the path is in the
            # user's home dir
            if ($($loc.ProviderPath).StartsWith($Home, $stringComparison)) {
                $ThisPath = "~" + $($loc.ProviderPath).SubString($Home.Length)
            }
            else {
                $ThisPath = $loc.ProviderPath
            }
            #$ThisPath = ($loc.ProviderPath -replace $([Regex]::Escape((Convert-Path '~'))),'~')
        }
        Default {
            $ThisPath = $loc.Path
        }
    }

    if ($realCommandStatus) {
        $PromptColor = $LastCommandSuccessForeground
    }
    else {
        $PromptColor = $LastCommandErrorForeground
    }

    # Maybe you can use this, maybe you don't care though so just leaving it commented out.
    try {
        $Elevated = Test-OMPIsElevated
    }
    catch {}

    if ($Elevated) {
        $host.ui.RawUI.WindowTitle = "(Admin) $ThisPath"
    }
    else {
        $host.ui.RawUI.WindowTitle = "$ThisPath"
    }

    # Other modules can mess with the foreground color, this sometimes fixes that (temporarily)
    $Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor

    Write-Host
    Write-Host "$PromptPrefix$ThisPath" -NoNewLine -ForegroundColor $PromptColor
    $global:LASTEXITCODE = $realLASTEXITCODE

    # Simple check for ConEmu existance and ANSI emulation enabled
    if ($env:ConEmuANSI -eq 'ON') {
        # Let ConEmu know when the prompt ends, to select typed
        # command properly with "Shift+Home", to change cursor
        # position in the prompt by simple mouse click, etc.
        $PromptSuffix += "$([char]27)]9;12$([char]7)"

        # And current working directory (FileSystem)
        # ConEmu may show full path or just current folder name
        # in the Tab label (check Tab templates)
        # Also this knowledge is crucial to process hyperlinks clicks
        # on files in the output from compilers and source control
        # systems (git, hg, ...)
        if ($loc.Provider.Name -eq 'FileSystem') {
            $PromptSuffix += "$([char]27)]9;9;`"$($loc.Path)`"$([char]7)"
        }
    }
    if (-not $promptSuffix) {
        $promptSuffix = ' '
    }

    $PromptSuffix
}