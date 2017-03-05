if (-not $Script:ModulePath) {
    $ModulePath = Split-Path $script:MyInvocation.MyCommand.Path
}

# This is used for the PSColor functions
$Script:PSColor = @{
    File = @{
        Default    = @{ Color = 'White' }
        Directory  = @{ Color = 'Cyan'}
        Hidden     = @{ Color = 'DarkGray'; Pattern = '^\.' }
        Code       = @{ Color = 'Magenta'; Pattern = '\.(java|c|cpp|cs|js|css|html)$' }
        Executable = @{ Color = 'Red'; Pattern = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$' }
        Text       = @{ Color = 'Yellow'; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown)$' }
        Compressed = @{ Color = 'Green'; Pattern = '\.(zip|tar|gz|rar|jar|war)$' }
    }
    Service = @{
        Default = @{ Color = 'White' }
        Running = @{ Color = 'DarkGreen' }
        Stopped = @{ Color = 'DarkRed' }
    }
    Match = @{
        Default    = @{ Color = 'White' }
        Path       = @{ Color = 'Cyan'}
        LineNumber = @{ Color = 'Yellow' }
        Line       = @{ Color = 'White' }
    }
}
$script:showHeader=$true

# For each type we will 'colorizing' create an entry to map an action
$script:PSColorTypeMap = @{
    'System.IO.DirectoryInfo' = {
        if ($script:showHeader) {
            Write-Host
            Write-Host "    Directory: " -noNewLine
            Write-Host " $(pwd)`n" -foregroundcolor "Green"
            Write-Host "Mode                LastWriteTime     Length Name"
            Write-Host "----                -------------     ------ ----"
            $script:showHeader=$false
        }
        Write-host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode, ([String]::Format("{0,10}  {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))), (Write-FileLength $_.length), $_.name) -foregroundcolor $Script:PSColor.File.Directory.Color
    }
    'System.IO.FileInfo' = {
        if ($script:showHeader) {
            Write-Host
            Write-Host "    Directory: " -noNewLine
            Write-Host " $(pwd)`n" -foregroundcolor "Green"
            Write-Host "Mode                LastWriteTime     Length Name"
            Write-Host "----                -------------     ------ ----"
            $script:showHeader=$false
        }
        if (([regex]::new($Script:PSColor.File.Hidden.Pattern,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).IsMatch($_.Name)) {
            # Match Hidden
            Write-host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode, ([String]::Format("{0,10}  {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))), (Write-FileLength $_.length), $_.name) -foregroundcolor $Script:PSColor.File.Hidden.Color
        }
        elseif (([regex]::new($Script:PSColor.File.Code.Pattern,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).IsMatch($_.Name)){
            # Match code
            Write-host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode, ([String]::Format("{0,10}  {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))), (Write-FileLength $_.length), $_.name) -foregroundcolor $Script:PSColor.File.Code.Color
        }
        elseif (([regex]::new($Script:PSColor.File.Executable.Pattern,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).IsMatch($_.Name)){
            # Match executable
            Write-host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode, ([String]::Format("{0,10}  {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))), (Write-FileLength $_.length), $_.name) -foregroundcolor $Script:PSColor.File.Executable.Color
        }
        elseif (([regex]::new($Script:PSColor.File.Text.Pattern,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).IsMatch($_.Name)){
            # Match text
            Write-host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode, ([String]::Format("{0,10}  {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))), (Write-FileLength $_.length), $_.name) -foregroundcolor $Script:PSColor.File.Text.Color
        }
        elseif (([regex]::new($Script:PSColor.File.Compressed.Pattern,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).IsMatch($_.Name)){
            # Match compressed
            Write-host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode, ([String]::Format("{0,10}  {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))), (Write-FileLength $_.length), $_.name) -foregroundcolor $Script:PSColor.File.Compressed.Color
        }
        else {
            # Default
            Write-host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode, ([String]::Format("{0,10}  {1,8}", $_.LastWriteTime.ToString("d"), $_.LastWriteTime.ToString("t"))), (Write-FileLength $_.length), $_.name) -foregroundcolor $Script:PSColor.File.Default.Color
        }
    }
    'System.ServiceProcess.ServiceController' = {
        if($script:showHeader) {
            Write-Host
            Write-Host "Status   Name               DisplayName"
            $script:showHeader=$false
        }
        if ($_.Status -eq 'Stopped') {
            Write-host ("{0,-8}" -f 'Stopped') -foregroundcolor $Script:PSColor.Service.Stopped.Color -noNewLine
        }
        elseif ($_.Status -eq 'Running') {
            Write-host ("{0,-8}" -f 'Running') -foregroundcolor $Script:PSColor.Service.Running.Color -noNewLine
        }
        else {
            Write-host ("{0,-8}" -f $_.Status) -foregroundcolor $Script:PSColor.Service.Default.Color -noNewLine
        }
        Write-host (" {0,-18} {1,-39}" -f (Write-CutString $_.Name 18), (Write-CutString $_.DisplayName 38)) -foregroundcolor "white"
    }
    'Microsoft.Powershell.Commands.MatchInfo' = {
        Write-host $_.RelativePath($pwd) -foregroundcolor $Script:PSColor.Match.Path.Color -noNewLine
        Write-host ':' -foregroundcolor $Script:PSColor.Match.Default.Color -noNewLine
        Write-host $_.LineNumber -foregroundcolor $Script:PSColor.Match.LineNumber.Color -noNewLine
        Write-host ':' -foregroundcolor $Script:PSColor.Match.Default.Color -noNewLine
        Write-host $_.Line -foregroundcolor $Script:PSColor.Match.Line.Color
    }
     'OMP.PluginStatus' = {
        if($script:showHeader) {
            Write-Host
            Write-Host "Name              Loaded"
            Write-Host "----              ------"
            $script:showHeader=$false
        }
        Write-host ("{0,-18}" -f (Write-CutString $_.Name 18)) -foregroundcolor "white" -noNewLine
        if ($_.Loaded) {
            Write-host ("{0,-8}" -f $_.Loaded) -foregroundcolor 'Green'
        }
        else {
            Write-host ("{0,-8}" -f $_.Loaded) -foregroundcolor 'Red'
        }
    }
}

# We define this for later use in out-default to reduce processing a teeny bit
$Script:PSColorTypeMapKeys = ($script:PSColorTypeMap).Keys