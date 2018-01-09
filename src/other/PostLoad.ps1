# These are core settings which we will not allow to ever get removed
$Script:OMPProfileCoreSettings = @(
    'AutoLoadModules',
    'AutoInstallModules',
    'Plugins',
    'PersonalFunctions',
    'Theme',
    'UnloadModulesOnExit',
    'OMPRunCount',
    'OMPPluginRootPaths',
    'OMPDebug',
    'OMPGitOutput'
)

<#
    Fill out each of the setting hash entries with some sensible defaults.
    This is the master template for user profile settings. Once the module runs once these
    settings are effectively ignored and should be managed via the exported functions instead.
#>
$Script:OMPProfile = @{
    # Load these modules with your OMP profile
    AutoLoadModules = @()
    # Download modules if missing?
    AutoInstallModules = $true
    # Which plugins would you like to load?
    Plugins = @()
    # Personal functions are like plugins but less structured
    PersonalFunctions = @()
    # Theme
    Theme = $null
    # If this is true we will attempt to unload any modules that weren't already loaded when we started
    UnloadModulesOnExit = $true
    # Used to display first time help or just keep a run of how much you love this module
    OMPRunCount = 0
    # Plugins can be located in many locations, this is the list of paths they may reside in
    OMPPluginRootPaths = @((Join-Path $ModulePath "plugins"))
    # Use this to see additional output when loading the module
    OMPDebug = $false
    # Preferred git status method. Used in prompts, specifically in Write-OMPGitStatus. Can be:
    # posh-git (module), psgit (module), script/other (no module, use the crappy baked in scripts with this module instead).
    OMPGitOutput = 'script'
    OMPModuleInstallSplat = @{
        'AllowClobber' = $true
        'Force' = $true
        'Scope' = 'CurrentUser'
    }
}

# Load any persistent data (overrides anything in OMPSettings if the hash element exists)
if ((Test-Path $OMPProfileExportFile)) {
    try {
        Import-OMPProfile -Path $OMPProfileExportFile
    }
    catch {
        throw "Unable to load the OMP profile: $OMPProfileExportFile"
    }
}

$VerbosityFlag = @{}
if ($Script:OMPProfile['OMPDebug']) {
    $VerbosityFlag.Verbose = $true
    $Script:OldVerbosePreference = $VerbosePreference
    $VerbosePreference = "Continue"
}

# We need to keep some state information outside of the profile. This is the hash
# used for this purpose. This combined with Get-OMPState can speed up some operations.
# This is only able to be updated by OMP functions.
$OMPState = @{
    PluginsLoaded = @()
    ModulesAlreadyLoaded = @((Get-Module).Name)
    Platform = Get-OMPOSPlatform
}

<#
    Perform profile processing, this is where all the fun begins...
#>

# 1. Load any specified autoload modules
$Script:OMPProfile['AutoLoadModules'] | Import-OMPModule @VerbosityFlag

# 2. Now the personal functions
$Script:OMPProfile['PersonalFunctions'] | Foreach-Object {
    try {
        Invoke-OMPPersonalFunction -Path $_ -Tag 'personalfunction'
    }
    catch {}
}

# 3. Now the plugins
Write-Verbose 'Loading Plugins:'
Foreach ($Plugin in ($Script:OMPProfile['Plugins'] | Sort-Object)) {
    Write-Verbose "Attempting to load plugin $Plugin"
    try {
        Add-OMPPlugin -Name $Plugin -NoProfileUpdate @VerbosityFlag
        Write-Verbose "Plugin Loaded: $Plugin"
    }
    catch {
        Write-Warning "Unable to load the following plugin: $($_)"
    }
}

# 4. Next the theme
try {
    $Theme = $Script:OMPProfile['Theme']
    if (-not [string]::IsNullOrEmpty($Script:OMPProfile['Theme'])) {
        Set-OMPTheme -Name $Theme -NoProfileUpdate
        Write-Verbose "Theme Loaded: $($Theme)"
    }
}
catch {
    Write-Warning "Unable to load the following theme: $($Theme)"
}

# 5. If we made it this far then we can bump up our run count by 1, save,
#     and continue processing items that rely upon this number
$Script:OMPProfile['OMPRunCount'] += 1
Export-OMPProfile -Path $OMPProfileExportFile

########################################################################
# Action to take if the module is removed
$ExecutionContext.SessionState.Module.OnRemove = {
    # Any functions loaded as plugins will get removed from the pssession
    Write-Output "Removing plugin or other dot sourced functions performed within OhMyPsh.."
    Get-ChildItem -Path Function:\ -Recurse | Where-Object { $_.ohmypsh -ne $null } | Remove-Item -Force

    # Run any plugin shutdown code blocks
    Write-Output "Processing OhMyPsh plugin shutdown scriptblocks"
    Invoke-OMPPluginShutdown

    # Remove any newly loaded modules since we started (if enabled)
    if ($Script:OMPProfile['UnloadModulesOnExit']) {
        Write-Output "Removing any modules loaded since OhMyPsh started"
        Get-Module | Where-Object {$OMPState['ModulesAlreadyLoaded'] -notcontains $_.Name} | Foreach-Object {
            if ($_.Name -ne 'OhMyPsh') {
                Write-Output "    Module being removed from this session: $($_.Name)"
                Remove-Module -Name $_.Name -Force
            }
        }
    }
    # Restore prompts, tabcompletion, aliases, and console settings
    Restore-OMPConsolePrompt
    Restore-OMPOriginalTabCompletion
    Restore-OMPOriginalPSDefaultParameter
    Restore-OMPOriginalAlias
    Restore-OMPConsoleTitle
    Restore-OMPConsoleColor
}


$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {
    # Action to take if the whole pssession is killed
    # Run any plugin shutdown code blocks at the very least.
    Invoke-OMPPluginShutdown
}

if ($Script:OMPProfile['OMPDebug']) {
    $VerbosityFlag = @{}
    $VerbosePreference = $Script:OldVerbosePreference
}

$ThisModuleLoaded = $true