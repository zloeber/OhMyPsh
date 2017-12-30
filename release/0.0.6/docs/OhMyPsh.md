---
Module Name: OhMyPsh
Module Guid: 00000000-0000-0000-0000-000000000000
Download Help Link: https://github.com/zloeber/OhMyPsh/release/OhMyPsh/docs/OhMyPsh.md
Help Version: 0.0.6
Locale: en-US
---

# OhMyPsh Module
## Description
A PowerShell 5.0 console utility that uses a simple json configuration file to manage plugins, theming, module autoloading, module upgrading, module cleanup, and other chores so that you can be more productive in the shell.

## OhMyPsh Cmdlets
### [Add-OMPAutoLoadModule](Add-OMPAutoLoadModule.md)
Adds a module to be autoloaded when OMP starts up.

### [Add-OMPPersonalFunction](Add-OMPPersonalFunction.md)
Adds a function to be autoloaded into your session when OMP starts up.

### [Add-OMPPlugin](Add-OMPPlugin.md)
Dot sources a plugin

### [Add-OMPProfileSetting](Add-OMPProfileSetting.md)
Adds a new setting to the user profile settings if they do not already exist. Afterwards the profile is automatically exported and saved.

### [Export-OMPProfile](Export-OMPProfile.md)
Saves a user profile.

### [Get-OMPGitBranchName](Get-OMPGitBranchName.md)
Returns the git branch based on the current directory.

### [Get-OMPGitStatus](Get-OMPGitStatus.md)
Returns the git branch based on the current directory.

### [Get-OMPHostState](Get-OMPHostState.md)
Returns the console host initial state when OhMyPsh is loaded.

### [Get-OMPIPAddress](Get-OMPIPAddress.md)
Platform independant retrieval of the current primary IP address.

### [Get-OMPLoadedFunction](Get-OMPLoadedFunction.md)
Shows OhMyPsh sourced functions that have been loaded to this session.

### [GET-OMPOSPlatform](GET-OMPOSPlatform.md)
Retrieve the current OS platform.

### [Get-OMPPlugin](Get-OMPPlugin.md)
Shows plugins and their load state.

### [Get-OMPProfilePath](Get-OMPProfilePath.md)
Retrieve the current OhMyPsh profile path.

### [Get-OMPProfileSetting](Get-OMPProfileSetting.md)
Get one or all of the OMP settings.

### [Get-OMPPromptColor](Get-OMPPromptColor.md)
Display the Prompt color settings.

### [Get-OMPState](Get-OMPState.md)
Returns the current OhMyPsh state.

### [Get-OMPSystemUpTime](Get-OMPSystemUpTime.md)
Retreive platform independant uptime informaton (should run on both linux and windows properly).

### [Get-OMPTheme](Get-OMPTheme.md)
Shows themes and their load state.

### [Import-OMPModule](Import-OMPModule.md)
Attempt to load and optionally install a powershell module.

### [Import-OMPProfile](Import-OMPProfile.md)
Loads a user profile.

### [Invoke-OMPPluginShutdown](Invoke-OMPPluginShutdown.md)
Runs the shutdown code for a loaded plugin.

### [New-OMPPlugin](New-OMPPlugin.md)
Creates a new OMP Plugin template.

### [New-OMPPluginManifest](New-OMPPluginManifest.md)
Creates a new OMP Plugin manifest file.

### [Optimize-OMPProfile](Optimize-OMPProfile.md)
Runs ngen on powershell assemblies. This can sometimes optimize startup times for PowerShell.

### [Remove-OMPAutoLoadModule](Remove-OMPAutoLoadModule.md)
Removes a module to be autoloaded when OMP starts up.

### [Remove-OMPModule](Remove-OMPModule.md)
Removes a module from this session.

### [Remove-OMPPersonalFunction](Remove-OMPPersonalFunction.md)
Removes a loaded personal function path from the profile.

### [Remove-OMPPlugin](Remove-OMPPlugin.md)
Removes a loaded plugin

### [Remove-OMPProfileSetting](Remove-OMPProfileSetting.md)
Removes a custom profile setting that is not one of the core settings. Afterwards the profile is automatically exported and saved.

### [Reset-OMPConsoleOverride](Reset-OMPConsoleOverride.md)
Resets various registry setting overrides for default console color values.

### [Restore-OMPConsoleColor](Restore-OMPConsoleColor.md)
Restores the original console colors.

### [Restore-OMPConsolePrompt](Restore-OMPConsolePrompt.md)
Restores the original powershell prompt function.

### [Restore-OMPConsoleTitle](Restore-OMPConsoleTitle.md)
Restores the original console colors and title.

### [Restore-OMPOriginalAlias](Restore-OMPOriginalAlias.md)
Restores original aliases that are backed up when this module initially loads.

### [Restore-OMPOriginalPSDefaultParameter](Restore-OMPOriginalPSDefaultParameter.md)
Restores the original powershell PSDefaultParameters variable.

### [Restore-OMPOriginalTabCompletion](Restore-OMPOriginalTabCompletion.md)
Restores the original powershell TabCompletion and TabCompletion2 functions.

### [Restore-OMPPSReadline](Restore-OMPPSReadline.md)
Restores the original PSReadline colors and settings.

### [Set-OMPConsoleColor](Set-OMPConsoleColor.md)
Sets different console colors.

### [Set-OMPGitOutput](Set-OMPGitOutput.md)
Sets the default git output module. This can be used to flip between posh-git and psgit modules.

### [Set-OMPProfileSetting](Set-OMPProfileSetting.md)
Set one of the OMP settings.

### [Set-OMPTheme](Set-OMPTheme.md)
Sets the theme.

### [Set-OMPWindowTitle](Set-OMPWindowTitle.md)
Sets the Host window title.

### [Show-OMPHelp](Show-OMPHelp.md)
Shows OhMyPsh basic help.

### [Show-OMPStatus](Show-OMPStatus.md)
Shows OhMyPsh basic status information.

### [Test-OMPConsoleHasANSI](Test-OMPConsoleHasANSI.md)
Validates if the current console has ANSI support.

### [Test-OMPInAGitRepo](Test-OMPInAGitRepo.md)
Validate if the current path is a git repo.

### [Test-OMPIsElevated](Test-OMPIsElevated.md)
Platform independant validation if the current user is elevated as root or administrator.

### [Test-OMPProfileSetting](Test-OMPProfileSetting.md)
Check if a profile setting exists.

### [Write-OMPGitStatus](Write-OMPGitStatus.md)
Outputs to the screen a short output of the current directory git status.


