<#
    EZOut Plugin
#>
$PreLoad = {
    $Global:OMPConsoleHasANSI = Test-OMPConsoleHasANSI
    if ($OMPConsoleHasANSI) {
        Import-OMPModule Pansies
    }

    Import-OMPModule EZOut
}

$PostLoad = {
    # Used to determine if we can display ANSI color in output, stored for later to reduce output overhead.

    $Global:OMPPansiesModuleLoaded = if (get-module pansies) {$true} else {$false}
    $Global:OMPEzOutPluginLoaded = $true

    $ThisPluginPath = Join-Path $PluginPath $Name
    $FormatFilesPath = Join-Path $ThisPluginPath 'formats'

    # Files and Directories (get-childitem)
    $PS1XMLOut = Join-Path $FormatFilesPath ('FilesAndDirectories.format.ps1xml')
    Write-FormatView -TypeName 'System.IO.DirectoryInfo','System.IO.FileInfo' -Property Mode, LastWriteTime, Length, Name -AutoSize -VirtualProperty @{
        Mode = {
            $_.Mode
        }
        LastWriteTime = {
            [String]::Format("{0,10}  {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))
        }
        Length = {
            if ($_ -is [System.IO.FileInfo]) {
                $_.Length
            }
        }
        Name = {
            $name = $_.Name
            if ($OMPPansiesModuleLoaded -and ($null -ne (get-variable OMPEZOutDefinitions)) -and $Global:OMPConsoleHasANSI -and $Global:OMPEzOutPluginLoaded) {
                $revertcolor = New-Text -Object "" -ForegroundColor ((Get-OMPHostState).foreground) -ErrorAction:SilentlyContinue
                $IgnoreCase = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase

                if ($_ -is [System.IO.DirectoryInfo]) {
                    $nameout = New-Text -Foregroundcolor $Global:OMPEZOutDefinitions['File'].DefaultDirectoryForeground -Object $name
                }
                else {
                    $nameout = New-Text -Foregroundcolor $Global:OMPEZOutDefinitions['File'].DefaultFileForeground -Object $name
                }

                Foreach ($P in ($Global:OMPEZOutDefinitions['File'].Patterns).keys) {
                    if (([regex]::new($Global:OMPEZOutDefinitions['File'].Patterns[$P].Pattern, $IgnoreCase)).IsMatch($name)) {
                        $nameout.foregroundcolor = $Global:OMPEZOutDefinitions['File'].Patterns[$P].Color
                        break
                    }
                }

                [string]$finaloutput = $nameout.ToString() + $revertcolor.ToString()# + "$([char](27))[0m"

                $finaloutput
            }
            else {
                $name
            }
        }
    } | Out-FormatData | Out-File -FilePath $PS1XMLOut -Force -Encoding:utf8
    Update-FormatData -PrependPath $PS1XMLOut

    # Services (Get-Service)
    $PS1XMLOut = Join-Path $FormatFilesPath ('Services.format.ps1xml')
    Write-FormatView -TypeName 'System.ServiceProcess.ServiceController' -Property Status, Name, DisplayName -AutoSize -VirtualProperty @{
        Status = {
            $status = $_.Status

            if ($OMPPansiesModuleLoaded -and ($null -ne (get-variable OMPEZOutDefinitions)) -and $OMPConsoleHasANSI -and $Global:OMPEzOutPluginLoaded) {
                $revertcolor = New-Text -Object "" -ForegroundColor ((Get-OMPHostState).foreground) -ErrorAction:SilentlyContinue
                switch ($status) {
                    'Stopped' {
                        $statusout = New-Text -Object $status -Foregroundcolor $Global:OMPEZOutDefinitions['Service'].Stopped['Color']
                    }
                    'Running' {
                        $statusout = New-Text -Object $status -Foregroundcolor $Global:OMPEZOutDefinitions['Service'].Running['Color']
                    }
                    'Starting' {
                        $statusout = New-Text -Object $status -Foregroundcolor $Global:OMPEZOutDefinitions['Service'].Starting['Color']
                    }
                    Default {
                        $statusout = New-Text -Object $status -Foregroundcolor $Global:OMPEZOutDefinitions['Service'].Default['Color']
                    }
                }

                # Pansies likes to reset the default color to white for some reason, this resets the color correctly.
                [string]$finaloutput = $statusout.ToString() + $revertcolor.ToString() # + "$([char](27))[0m"

                $finaloutput
            }
            else {
                $status
            }
        }
        Name = {
            $_.Name
        }
        DisplayName = {
            $_.DisplayName
        }
    } | Out-FormatData | Out-File -FilePath $PS1XMLOut -Force -Encoding:utf8
    Update-FormatData -PrependPath $PS1XMLOut

    # Match Info (select-string or similar)
    $PS1XMLOut = Join-Path $FormatFilesPath ('MatchInfo.format.ps1xml')
    Write-FormatView -TypeName 'Microsoft.Powershell.Commands.MatchInfo' -Property Path, LineNumber, Line -AutoSize -VirtualProperty @{
        Path = {
            if ($OMPPansiesModuleLoaded -and ($null -ne (get-variable OMPEZOutDefinitions)) -and $OMPConsoleHasANSI -and $Global:OMPEzOutPluginLoaded) {
                $revertcolor = New-Text -Object "" -ForegroundColor ((Get-OMPHostState).foreground) -ErrorAction:SilentlyContinue

                $PathOut = New-Text -Object ($_.RelativePath($pwd)) -Foregroundcolor $Global:OMPEZOutDefinitions['Match'].Path['Color']

                # Pansies likes to reset the default color to white for some reason, this resets the color correctly.
                [string]$finaloutput = $PathOut.ToString() + $revertcolor.ToString()
                $finaloutput
            }
            else {
                $_.RelativePath($pwd)
            }
        }
        LineNumber = {
            if ($OMPPansiesModuleLoaded -and ($null -ne (get-variable OMPEZOutDefinitions)) -and $OMPConsoleHasANSI -and $Global:OMPEzOutPluginLoaded) {
                $revertcolor = New-Text -Object "" -ForegroundColor ((Get-OMPHostState).foreground) -ErrorAction:SilentlyContinue
                $LineNumberOut = New-Text -Object ($_.LineNumber) -Foregroundcolor $Global:OMPEZOutDefinitions['Match'].LineNumber['Color']

                # Pansies likes to reset the default color to white for some reason, this resets the color correctly.
                [string]$finaloutput = $LineNumberOut.ToString() + $revertcolor.ToString()
                $finaloutput
            }
            else {
                $_.LineNumber
            }
        }
        Line = {
            if ($OMPPansiesModuleLoaded -and ($null -ne (get-variable OMPEZOutDefinitions)) -and $OMPConsoleHasANSI -and $Global:OMPEzOutPluginLoaded ) {
                $revertcolor = New-Text -Object "" -ForegroundColor ((Get-OMPHostState).foreground) -ErrorAction:SilentlyContinue
                $startofright = $_.Matches.Index + $_.Matches.Value.Length
                $endofright = ($_.line.length - $startofright)
                $leftoutput = New-Text -Object ($_.Line).Substring(0,($_.Matches).Index) -Foregroundcolor $Global:OMPEZOutDefinitions['Match'].Line['Color']
                $matchoutput = New-Text -Object ($_.Matches).Value -Foregroundcolor $Global:OMPEZOutDefinitions['Match'].Match['Color']
                $rightoutput = New-Text -Object ($_.Line).Substring($startofright, $endofright) -Foregroundcolor $Global:OMPEZOutDefinitions['Match'].Line['Color']
                # Pansies likes to reset the default color to white for some reason, this resets the color correctly.
                [string]$finaloutput = $leftoutput.ToString() + $matchoutput.ToString() + $rightoutput.ToString() + $revertcolor.ToString()

                $finaloutput
            }
            else {
                $_.Line
            }
        }
    } | Out-FormatData | Out-File -FilePath $PS1XMLOut -Force -Encoding:utf8
    Update-FormatData -PrependPath $PS1XMLOut

    # OMP Plugin Status (Get-OMPPlugin)
    $PS1XMLOut = Join-Path $FormatFilesPath ('OMPPluginStatus.format.ps1xml')
    Write-FormatView -TypeName 'OMP.PluginStatus' -Property Name, Loaded -AutoSize -VirtualProperty @{
        Name = {
            $_.Name
        }
        Loaded = {
            if ($OMPPansiesModuleLoaded -and ($null -ne (get-variable OMPEZOutDefinitions)) -and $OMPConsoleHasANSI -and $Global:OMPEzOutPluginLoaded ) {
                $revertcolor = New-Text -Object "" -ForegroundColor ((Get-OMPHostState).foreground) -ErrorAction:SilentlyContinue
                if ($_.Loaded) {
                    $statusout = New-Text -Object ($_.Loaded) -Foregroundcolor $Global:OMPEZOutDefinitions['OMPStatus'].Loaded['Color']
                }
                else {
                    $statusout = New-Text -Object ($_.Loaded) -Foregroundcolor $Global:OMPEZOutDefinitions['OMPStatus'].UnLoaded['Color']
                }

                [string]$finaloutput = $statusout.ToString() + $revertcolor.ToString()

                $finaloutput
            }
            else {
                $_.Loaded
            }
        }
    } | Out-FormatData | Out-File -FilePath $PS1XMLOut -Force -Encoding:utf8
    Update-FormatData -PrependPath $PS1XMLOut
}

$Config = {
    $Global:OMPEZOutDefinitions = @{
        File = @{
            DefaultFileForeground = 'White'
            DefaultDirectoryForeground = 'Cyan'
            Patterns = @{
                Hidden     = @{ Color = 'DarkGray'; Pattern = '^\.' }
                Code       = @{ Color = 'Magenta'; Pattern = '\.(java|c|cpp|cs|js|css|html)$' }
                Executable = @{ Color = 'Red'; Pattern = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$' }
                Text       = @{ Color = 'Yellow'; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown)$' }
                Compressed = @{ Color = 'Green'; Pattern = '\.(zip|tar|gz|rar|jar|war)$' }
            }
        }
        Service = @{
            Default = @{ Color = 'White' }
            Running = @{ Color = 'DarkGreen' }
            Stopped = @{ Color = 'DarkRed' }
            Starting = @{ Color = 'Yellow' }
        }
        Match = @{
            Default    = @{ Color = 'White' }
            Path       = @{ Color = 'White'}
            LineNumber = @{ Color = 'Yellow' }
            Line       = @{ Color = 'Gray' }
            Match      = @{ Color = 'Cyan' }
        }
        OMPStatus = @{
            Loaded  = @{ Color = 'Green' }
            Unloaded  = @{ Color = 'Red' }
        }
    }
}
$Shutdown = {}

$Unload = {
    Remove-Module EZOut -ErrorAction:SilentlyContinue
    $Global:OMPEzOutPluginLoaded = $false
    #Remove-Module Pansies -ErrorAction:SilentlyContinue
    #Remove-Variable OMPConsoleHasANSI -ErrorAction:SilentlyContinue
    #Remove-Variable OMPPansiesModuleLoaded -ErrorAction:SilentlyContinue
    #Remove-Variable OMPEZOutDefinitions -ErrorAction:SilentlyContinue
}