# OhMyPsh

A PowerShell 5.0 console utility that uses a simple json configuration file to manage plugins, theming, module autoloading, module upgrading, module cleanup, and other chores so that you can be more productive in the shell.

## Release Notes

**0.0.2**
- Resolve psdefaultparams plugin settings
- Fix the build script
- Set-OMPTheme now automatically saves the set theme if it loads properly.
- Added 'Connect-ExchangeMFA' to the o365 plugin
- Added the 'Config' scriptblock plugin for persisting plugin settings through upgrades of OhMyPsh
- Combined plugin code into one ps1 file called 'Load.ps1' that includes Preload, Postload, Config, Shutdown, and Unload scriptblocks.

**0.0.1**
- Initial Release