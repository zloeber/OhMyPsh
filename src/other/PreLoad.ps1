param(
    [parameter(Position=0)]
    [string]$UserProfilePath
)

if (-not [string]::IsNullOrEmpty($UserProfilePath)) {
    if ((Test-Path -Path $UserProfilePath -PathType:Container)) {
        $Script:UserProfilePath = Resolve-Path -Path $UserProfilePath
    }
    else {
        throw "Invalid OhMyPsh profile path: $UserProfilePath"
    }
}
else {
        if ((Get-Variable 'PROFILE' -ErrorAction:SilentlyContinue) -eq $null) {
        throw 'No profile variable found!'
    }
    $Script:UserProfilePath = Split-Path $PROFILE
}

$OMPProfileExportFile = Join-Path $UserProfilePath '.OhMyPsh.config.json'
$IsConEmuConsole = if ($null -ne $env:ConEmuANSI) {$true} else {$false}

# Backup some basic host settings. these never get updated and are used for restore purposes.
$Script:HostState = @{
    Title = $Host.UI.RawUI.WindowTitle
    Background = $Host.UI.RawUI.BackgroundColor
    Foreground = $Host.UI.RawUI.ForegroundColor
    Prompt = $function:prompt
    TabExpansion = $function:TabExpansion
    TabExpansion2 = $function:TabExpansion2
    PSDefaultParameterValues =  $Global:PSDefaultParameterValues.Clone()
    Aliases = Join-Path $UserProfilePath '.OhMyPsh.aliasbackup.ps1'
    Modules = (Get-Module).Name
    Colors = @{
        BackgroundColor = $Host.UI.RawUI.BackgroundColor
        ForegroundColor = $Host.UI.RawUI.ForegroundColor
        ErrorForegroundColor = $Host.PrivateData.ErrorForegroundColor
        WarningForegroundColor = $Host.PrivateData.WarningForegroundColor
        DebugForegroundColor = $Host.PrivateData.DebugForegroundColor
        VerboseForegroundColor = $Host.PrivateData.VerboseForegroundColor
        ProgressForegroundColor = $Host.PrivateData.ProgressForegroundColor
        ErrorBackgroundColor = $Host.PrivateData.ErrorBackgroundColor
        WarningBackgroundColor  = $Host.PrivateData.WarningBackgroundColor
        DebugBackgroundColor = $Host.PrivateData.DebugBackgroundColor
        VerboseBackgroundColor = $Host.PrivateData.VerboseBackgroundColor
        ProgressBackgroundColor = $Host.PrivateData.ProgressBackgroundColor
    }
}

if (get-module psreadline) {
    $Script:PSReadlineState = Get-PSReadlineOption
}
else {
    $Script:PSReadlineState = $null
}

if (-not $Script:ModulePath) {
    $ModulePath = Split-Path $script:MyInvocation.MyCommand.Path
}

# Backup original aliases
Get-Alias | Where {($_.Options -split ',') -notcontains 'ReadOnly'} | Export-Alias -Path $Script:HostState['Aliases'] -As Script -Force