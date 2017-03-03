# OhMyPsh

A PowerShell 5.0 console utility that uses a simple json configuration file to manage plugins, theming, module autoloading, module upgrading, module cleanup, and other chores so that you can be more productive in the shell.

## Introduction

I've tested out several custom PowerShell console modules and each had great features but none really met all my needs. In response to this I smashed up several projects in an effort to make a worthy customizable PowerShell experience. I've found that the results have been worth my time, I hope you do as well!

## Installation

Powershell Gallery (PS 5.0, Preferred method)

`install-module OhMyPsh`

Manual Installation

`iex (New-Object Net.WebClient).DownloadString("https://www.github.com/zloeber/OhMyPsh/raw/master/Install.ps1")`

Or clone this repository to your local machine, extract, go to the .\releases\OhMyPsh directory and import the module to your session to test, but not install this module.

## Features

OhMyPsh includes several appealing features for both the beginning and seasoned PowerShell user. This includes (but is not limited to):
- Automatic module installation
- Automatic module updating and cleaning (via plugins)
- Very easy addition, loading, and unloading of plugins and modules
- Theming (psreadline, pscolor, powerline, your imagination)
- Persistent custom profile settings (simple json)
- Integrated PSColor output (that can safely be unloaded)
- Automatic dot sourcing of personal functions from any location
- A good amount of cool plugins baked right in the base install

Read on to see how to use some of these features.

## Guide
Here is a general guide on some of the things you can do with this module.

### Quick Start
The starting profile of OhMyPsh is rather plain (I have to keep it this way for the build process not to freak out). If you want to get up and running ASAP with a good default setup this code block will suffice:

```
install-module OhMyPsh
import-module OhMyPsh
Add-OMPPlugin psreadline
Add-OMPPlugin pscolor
Add-OMPPlugin banner
Add-OMPPlugin psdefaultparams
Add-OMPPlugin qod
Add-OMPPlugin fzf
Add-OMPPlugin powerline
Add-OMPPlugin psgit
Add-OMPPlugin moduleupgrade
Add-OMPPlugin moduleclean
Set-OMPTheme powerline
```
This will install the module, load it for the first time, enable a handlful of my favorite plugins and set a default theme. Along the way, any missing modules should automatically get installed on your system (psgit and powerline specifically).

This now also does a few more fun things for you like setup a few psreadline settings (F1 to open a new help window about the current PowerShell command among other things).

By default, we don't futz with your powershell profile but if you wanted to load OhMyPsh everytime you launched a new console you can add something like the following to your Powershell profile.

Open your profile for editing....

```
notepad.exe $Profile
```

Add the following at the end....
```
if (($Host.Name -eq 'PowerGUIScriptEditorHost') -or (($Host.Name -eq 'ConsoleHost') -and (-not $NOCONSOLE))) {
    Import-Module OhMyPsh
}
```

Here is my own profile if anyone is interested.

```
##  PS5 introduced PSReadLine, which chokes in non-console shells, so I snuff it.
try {
    $NOCONSOLE = $FALSE
    [System.Console]::Clear()
}
catch {
    $NOCONSOLE = $TRUE
}

##  Check SHIFT/CTRL state ASAP at startup so we can control verbosity and if OhMyPsh will be loaded
Add-Type -Assembly PresentationCore, WindowsBase
try {
    $ForceVerbose = [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -or [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)
    $LoadOhMyPsh = -not ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftCtrl) -or [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightCtrl))
}
catch {
    $ForceVerbose = $false
    $LoadOhMyPsh = $true
}

## Set the profile directory first, so we can refer to it from now on.
Set-Variable ProfileDir (Split-Path $MyInvocation.MyCommand.Path -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue

if($ForceVerbose) {
    $VerbosePreference = "Continue"
}

if (($Host.Name -eq 'ConsoleHost') -and
    (-not $NOCONSOLE) -and
    ($LoadOhMyPsh)) {
    if (Get-Module OhMyPsh -ListAvailable) {
        Import-Module OhMyPsh
    }
}

## And finally, relax the code signing restriction so we can actually get work done
Set-ExecutionPolicy RemoteSigned Process
```

### Plugins

Plugins in OhMyPsh are PowerShell scripts that import functions/variables/aliases into your session in a seamless manner. These are extremely powerful and versitile with only a nominal amount of effort to create and deploy. Several plugins are included with the module for your convenience. You can get a list of available plugins and if they are loaded with the following command:

```
╔ #239 ~:
╚═══╕ Get-OMPPlugin

Name              Loaded
----              ------
banner            True
consoleui         False
fileutils         False
fzf               True
helpers           True
moduleclean       True
moduleupgrade     True
net               False
o365              True
powerline         True
psdefaultparams   True
psgit             True
psreadline        True
qod               True
vagrant           False
vmware            False
```

#### Builtin Plugins
I've packaged up several useful (or sometimes just amusing) plugins as examples of what this module can do with nominal effort. A good portion of these are mostly a mini-collection of functions that could also be modules if you wanted to go that route. Here is a description of each of them.

##### PSReadline
I'm listing this one first for a reason. Several other plugins and features simply don't exist without this module running. As PowerShell 5.0 loads this module by default in every session this plugin doesn't really serve to ensure that the module is loaded (though it does do that as well) but rather acts as a holding place for psreadline customizations you want applied across the board.

This plugin also puts logic around loading prior session history into new sessions (the default is 50 items).

You should feel free to modify your psreadline configuration to suit your needs.

```
plugins -> psreadline -> src -> psreadline.ps1
```

This plugin does add a few variables to the OhMyPsh user profile

--PSReadlineHistoryPath-- - You may want to modify this to live on Onedrive or Dropbox. The default location is in `Split-Path $PROFILE`

PSReadlinePersistantHistoryCount - This determines how many previous history items are loaded into a fresh session. The default is 50.

PSReadlineHistoryLoaded - This is used to track if history was loaded or not. This will prevent multiple import/exports of OhMyPsh from screwing up your history buffer. It gets set to $false when the entire session is killed and gets set to true again the next time OhMyPsh loads up in another session. (Note, multiple sessions thusly do not load the history from one another but you can still use the psreadline history search buffer to find entries from other sessions).

##### Banner

This is a simple plugin to show a pretty system info banner when you startup OhMyPsh. The banner looks something like the following:

```
Dom:<Short Domain> | Host:<ComputerName> | Logon Svr:<DC>
PS:5 | Elevated:FALSE | Execution Policy:Bypass
User:zloeber | IP:10.0.x.x/24 | GW:10.0.x.x

Uptime (hardware boot): 3 days / 0 hours / 9 minutes
Uptime (system resume): 0 days / 1 hours / 56 minutes
```

##### Consoleui

This is just a small group of console related functions that get imported into your OhMyPsh session.

##### FileUtils

Like consoleui, this is just a handful of useful file utility functions. View these with `Get-OMPLoadedFunction`

##### Fzf

Simply put, using this plugin makes you look like a wizard at the console. This is actually a module disguised as a plugin as it hasn't been plublished to PowerShellGet yet. I've made some minor changes and included the underlying fzf.exe binary to encapsulate this all into a nice package. The underlying module, psfzf, wraps around fzf.exe which is a fuzzy logic console application. Here are a few small things you can do with this plugin.

- Ctrl+F = Search through your history in a cool new way (try invoke-FuzzyHistory to do the same but also launch the results!)
- Alt+C = Change your current directory like a boss!
- Alt+A = Parse through your argument history.

This is best combined with psreadline for the coolest results but you can also use the commands it exports (`get-command -Module psfzf`)

##### Helpers
Another small plugin with several helper functions and aliases you may find useful. View these with `Get-OMPLoadedFunction`

##### ModuleClean
This will prompt you for automatic removal of 'old' modules from your system. This only targets powershellget sourced modules and only will prompt for removal of those that have multiple versions installed. The following OhMyPsh profile variable is used to determine how frequently this occurs (in OhMyPsh module loads):

ModuleAutoCleanFrequency - Default is every 8 times OhMyPsh is loaded.

**NOTE**: the underlying function isn't heavily optimized and can take a while to process!

##### ModuleUpgrade
This will prompt you for automatic upgrade of 'old' modules on your system. This only targets powershellget sourced modules and only will prompt for upgrades of those that have upgrades available. The following OhMyPsh profile variable is used to determine how frequently this occurs (in OhMyPsh module loads):

ModuleAutoUpgradeFrequency - Default is every 7 times OhMyPsh is loaded.

**NOTE**: the underlying function isn't heavily optimized and can take a while to process!

##### Net
Another small plugin with networ related helper functions and aliases you may find useful. View these with `Get-OMPLoadedFunction`

##### o365
Another small plugin with several o365 functions and aliases you may find useful. View these with `Get-OMPLoadedFunction`

##### Powerline
An extremely powerful console prompt customization module. This plugin is a place you might put customizations for this module. This plugin is also required for the cool powerline theme included with OhMyPsh.

Note: I've yet to work out a module unload dependancy error when unloading this plugin but it is pretty harmless so I've left it in the first release of this project.

##### PSDefaultParams
This is an example of how you might use OhMyPsh to muck with your setting in a fairly safe manner. It will load several useful PSDefaultParameters settings like popping out a help window when using get-help and autosizing Format-Table output.

##### PSGit
After much deliberation I decided to get behind PSGit instead of posh-git as PSGit seems more PowerShell oriented and doesn't screw with your prompt or powershell profile when you load it.

##### QOD
Displays a quote of the day. Nuff said.

This parses a simple txt file which can be updated or moved. The file location is stored in the OhMyPsh variable that this plugin adds aptly called 'QuoteDirectory'

##### Vagrant
Imports the vagrant-status module functions into your session. Can be used for custom prompts if so desired.

##### VMware
Imports the VMware module if it exists. As the vmware module likes to be a bastard and change your prompt this plugin will load the module then change it right back the way you had it. Take that you prompt hijacker! I tend to add and remove this plugin as required to do my job.

#### Plugin Logic
Plugins reside in a directory of the same name as the plugin itself. There can be multiple root paths that are searched for plugins but, by default, the plugins folder within the module is used. If you want to add additional plugin paths (or change the existing one) you can modify the OMPPluginRootPaths profile setting (Set-OMPProfileSetting).

A plugin folder has the following structure:
```
Plugins
--PluginName (directory)
  --src (directory)
    --SomeDirectory (directory)
    --SomeScript.ps1
  --Load.ps1
```

A plugin Load.ps1 file consists of five distinct scriptblocks and a directory of optionally dot sourced files. The scriptblocks are as follows:
1. PreLoad
2. PostLoad
3. Config
4. Unload
5. Shutdown

When a plugin loads it first checks the plugin folder for the Load.ps1 file which contains the scriptblock definitions. Preload occurs before files are dot sourced from the src directory, PostLoad occurs afterwards. Then if a profile configuration for the plugin is defined it gets run (otherwise the default config scriptblock is run and added to the profile).  When the plugin is removed from a profile (via Remove-OMPPlugin) the Unload scriptblock is invoked. Finally, when the OhMyPsh module is unloaded then the Shutdown scriptblock is invoked.

So, in order this occurs for each plugin:
1. Invoke the Preload scriptblock
2. Find and invoke every .ps1 file in the plugin src subdirectory
3. Invoke the Postload scriptblock
4. Does a config scriptblock exist in the user's profile for the plugin? If so invoke it. If not invoke the default config scriptblock and save it to the user's profile.
5. Optionally, if the plugin is removed via Remove-OMPPlugin the Unload scriptblock is invoked.
6. Optionally, if you close your powershell session or unload OhMyPsh the Shutdown scriptblock (in the Load.ps1 file) is invoked.

**NOTE:** When a plugin is 'added' to a profile a new profile configuration item is created if it doesn't already exist. This will be called `pluginconfig_<pluginname>` and will contain the 'Config' scriptblock contents. This is to allow for plugin upgrades that will not overwrite any custom settings you may want to keep. This setting does NOT get removed when you remove the plugin.

**NOTE:** It is important to be aware that all scriptblock code is run in the module context and so anything that you want to flow back to the user session must be scoped globally. This includes functions and aliases. currently only global functions that get brought into the global session will be tracked by OhMyPsh and automatically removed when the plugin or module are unloaded. You can also import stand-alone functions that will get automatically converted to the global scope via Add-OMPPersonalFunction.

++EXAMPLE PLUGIN++ - Run some task every 5th time you load OhMyPsh

Perhaps you need your ego stroked a bit so you you decide to tell yourself how great you are every five times you load OhMyPsh. Easy stuff, first create your template plugin:

New-OMPPlugin -Name 'egoboost'

Next update the returned plugin.ps1 file path with the following code:

```
$Freq = 5
$TotalRuns = Get-OMPProfileSetting -Name:OMPRunCount
if (($TotalRuns % $Freq) -eq 0)) {
    Write-Verbose "Total OMP run count is a multiple of the egoboost frequency setting ($Freq)"
    Write-Output "I'm Good Enough, I'm Smart Enough, and Doggone It, People Like Me!"
}
```

Test and then add the new plugin to your persistent session:

```
Add-OMPPlugin -Name 'egoboost' -Force -NoProfileUpdate
Add-OMPPlugin -Name 'egoboost' -Force

```

Unload and reload the module a few times to be given your positive affirmation.

**NOTE!** Exported functions from plugins will not be shown with `get-command -module OhMyPsh`. If you want to get a quick view of the functions that are in your session because of plugins then use the following command:

```
Get-OMPLoadedFunction
```

### Dot Sourced Personal Functions
Rather than have to change a function you wrote just to work as a plugin (defining with a global scope) you can simply add it directly to be dot sourced in OhMyPsh. There are still some restrictions around how to do this though. Generally a fully formed left-justified function (using the actual function definition) within a ps1 file will be detected and automatically loaded into the global scope. As with plugins, these functions will get 'tracked' by OhMyPsh via a simple notepropery on the object so it can be later removed when OhMyPsh is unloaded.

These get saved in your OhMyPsh profile as individual ps1 files that will automatically get loaded the next time you start OhMyPsh (and get removed when OhMyPsh is unloaded).

Be careful as this was really meant for just function definitions in ps1 files. The whole ps1 file will get invoked no matter what you have in it though so use at your own discretion.

You can add personal function files or entire directories of them with `Add-OMPPersonalFunction`

**NOTE: I'd be a poor example if I didn't say that grouping several similar functions into a module is the preferred method of script distribution over using OhMyPsh personal functions or plugins.**

### Profile Configuration
A fairly plain default configuration is provided out of the box with this module. You can see all current settings with the following function:

```
Get-OMPProfileSetting
```

You can easily modify all of these settings without ever having to open the json save file in an editor. Use the Set-OMPProfileSetting function (which includes tab completion for all settings via the 'Name' Parameter BTW). These settings will instantly save to your persistent profile.

++EXAMPLE++ - Enable verbose output when loading your module

```
Set-OMPProfileSetting -Name:OMPDebug -Value:$false

```

You are also able to add and remove custom profile settings with Add-OMPProfileSetting and Remove-OMPProfileSetting commands. This allows for some rather creative plugins to be deployed. Take a look at the moduleupgrade and moduleclean plugins for a good example of how this is used.

### Themes
Themes are simply customized PSColor hash definitions and/or a prompt that get imported as a ps1 file. Set your theme with Set-OMPTheme.

++EXAMPLE++ - Set the theme to 'norm'

```
Set-OMPTheme -Name:norm

```

### PSColor Customization
I've absorbed the PSColor module functionality into this project and turned it into a plugin. All this really does is colorize output of a few commands based on the primary typename they spit out. These commands are:
- Get-OMPPLugin (I added this as a small example of how to add your own type)
- Get-Service
- Get-ChildItem
- Select-String (ie. gci .\ -Recurse -filter '*.ps1' | Select-string 'OhMyPsh')

Without the plugin you get nothing, so first add it to your profile:
```
Add-OMPPlugin pscolor
```
You can see all the definitions and types that get matched for this with the following:

```
Get-OMPColorAction | Select *
```

You are free to expand upon this output colorization using these examples and `Add-OMPColorAction`

You can also change the default colors used by updating the PSColor module hash (Get-OMPPSColor/Set-OMPPSColor)

### Some Known Issues
There are several areas of improvement that can be made:
- Probably should autoremove plugins from a profile if they fail to load
- Add script-signing support and validation
- Add module dependancy checking when unloading loaded modules
- Safer input validation of input to pscolor
- ~~Turn pscolor into a plugin instead of being integrated.~~
- I started a module variable for storing prompt colors that probably should be eliminated in favor of psreadline variables or anything else (Get-OMPPromptColor/Set-OMPPromptColor). This is used in the highly-stylized 'jaykul' theme.
- I should have some Pester tests for plugin authoring purposes (among other things)
- Figure out a way to get original aliases reimported when the module unloads. For now a script is created and message is displayed on how to re-import yourself if required.
- So much more I'm guessing :)

### Further Information
The entire module is pure powershell and is hosted on github for your convenience. https://www.github.com/zloeber/OhMyPsh

## Versions

0.0.1 - Initial Release

## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code]
* [PowerShell Extension]

This module can be a bit of a pain to build and test with the tenatious way that it tries to maintain persistency (via automatic loading of the json configuration file). You can load the module with a different path if desired so that your own user profile configuration file is not used.

 ```
Import-Module .\OhMyPsh.psm1 -ArgumentList '.\'
```

## Other Information

**Author:** Zachary Loeber

**Website:** https://www.github.com/zloeber/OhMyPsh

**Related Projects/Credits**
- [Oh-My-Posh (pecigonzalo)](https://github.com/pecigonzalo/Oh-My-Posh)
- [Oh-My-Posh (JanJoris)](https://github.com/JanJoris/oh-my-posh)
- [PSColor](https://github.com/Davlind/PSColor)
- [PSReadline](https://msdn.microsoft.com/en-us/powershell/reference/5.1/psreadline/psreadline)
- [Powerline](https://github.com/Jaykul/PowerLine)
- [PSGit](https://github.com/PoshCode/PSGit)
- [PSfzf](https://github.com/kelleyma49/PSFzf)
