$PreLoad = {
    $ThisPluginFullPath = Join-Path $PluginPath $Name
    $ConEmuThemes = Join-Path $ThisPluginFullPath 'Themes'
    if (-not (Test-Path $ConEmuThemes)) {
        try {
            git clone https://github.com/joonro/ConEmu-Color-Themes.git $ConEmuThemes
        }
        catch {
            throw "Unable to use git to pull a clone of the conemu themes project"
        }
    }
    else {
        try {
            git fetch $ConEmuThemes
        }
        catch {
            Write-Warning "Unable to update the conemu themes repo at $ConEmuThemes"
        }
    }

    if (-not (Test-OMPProfileSetting -Name 'ConEmuThemesLocation')) {
        $ConEmuThemes = Join-Path $ConEmuThemes "themes"
        Write-Output "Setting Conemu themes directory to $ConEmuThemes"
        Add-OMPProfileSetting -Name 'ConEmuThemesLocation' -Value $ConEmuThemes
        Export-OMPProfile
    }
}
$PostLoad = {}
$Config = {}
$Shutdown = {}
$Unload = {
    Remove-OMPProfileSetting -Name 'ConEmuThemesLocation'
}