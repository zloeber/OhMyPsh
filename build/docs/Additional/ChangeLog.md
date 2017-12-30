# OhMyPsh Change Log

Project Site: [https://github.com/zloeber/OhMyPsh](https://github.com/zloeber/OhMyPsh)

## Version 0.0.6
- Updated to most recent version of ModuleBuild
- Added pre and post build actions to make the build process easier if you are actively using OhMyPsh (but not by much)
- Moved some of the more problematic plugins back to plugin-dev until a better mechanism to handle author module updates (that break things) can be devised.
- Fixed the moduleclean plugin.
- Added dynamic parameters to several of the public functions.
- Cleaned up and upgraded the vscode build tasks
- Updated some documentation
- Added the chocolatey plugin
- Added plugin manifest files that can include plugin version and descriptions that can be retrieved with get-ompplugin.
- Removed pscolors entirely in favor of ezout as a plugin for colorizing output of select-string, get-service, get-childitem, and get-ompplugin

**0.0.2**
- Resolve psdefaultparams plugin settings
- Fix the build script
- Set-OMPTheme now automatically saves the set theme if it loads properly.
- Added 'Connect-ExchangeMFA' to the o365 plugin
- Added the 'Config' scriptblock plugin for persisting plugin settings through upgrades of OhMyPsh
- Combined plugin code into one ps1 file called 'Load.ps1' that includes Preload, Postload, Config, Shutdown, and Unload scriptblocks.

**0.0.1**
- Initial Release