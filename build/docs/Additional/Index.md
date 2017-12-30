# OhMyPsh
A PowerShell 5.0 console utility that uses a simple json configuration file to manage plugins, theming, module autoloading, module upgrading, module cleanup, and other chores so that you can be more productive in the shell.

Project Site: [https://github.com/zloeber/OhMyPsh](https://github.com/zloeber/OhMyPsh)

## What is OhMyPsh?
A PowerShell 5.0 console utility that uses a simple json configuration file to manage plugins, theming, module autoloading, module upgrading, module cleanup, and other chores so that you can be more productive in the shell.

## Why use the OhMyPsh Module?
If you have several functions you want to dot source into your profile regularly this project may be just what you need. This module also makes your PowerShell profile plugin capable which allows for endless customization options.

### Features
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

## Installation
OhMyPsh is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/OhMyPsh/).

To Inspect:
```powershell
Save-Module -Name OhMyPsh -Path <path>
```
To install:
```powershell
Install-Module -Name OhMyPsh -Scope CurrentUser
```

## Contributing
[Notes on contributing to this project](Contributing.md)

## Change Logs
[Change notes for each release](ChangeLogs.md)

## Acknowledgements
[Other projects or sources of inspiration](Acknowledgements.md)


