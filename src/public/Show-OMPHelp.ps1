function Show-OMPHelp {
    <#
    .Synopsis
    Shows OhMyPsh basic help.
    .DESCRIPTION
    Shows OhMyPsh basic help.
    .EXAMPLE
    PS> Show-OMPHelp

    Shows OhMyPsh help
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>

    [CmdletBinding()]
    param ()

    $Help = @'
Current OhMyPsh Profile: {{Profile}}
Loaded Plugins: {{Plugins}}

OhMyPsh Basics
This module is a personal profile management and profile loading wizard for PowerShell 5.0 (and greater) users that uses a simple
json configuration file to manage plugins, theming, module autoloading, module upgrading, module cleanup, and other chores so
that you can be more productive in the shell.

Plugin Power
Plugins are dot sourced files that run scripts or import functions/variables/aliases into your session in a seamless manner. These are extremely powerful and versitile with only a nominal amount of effort to create and deploy. Here are a few examples on what you might do with them:

    EXAMPLE 1 - Keep a dumping ground of your personal 'One-off' script functions.

    With this module you can quickly load one off functions in your profile every time you start this module. This is common for many users that simply need to use a particular function over and over but don't have a need to turn them into full blown modules.

    First create your plugin framwork automatically with:
        New-OMPPlugin -Name 'personalfunctions'
        New-OMPPluginManifest -Name 'personalfunctions' -Description 'My personal functions'

    Simply define the function in the global scope like so:

        function Global:MyFunction {
            Write-Output 'Test'
        }

    Then save the function (or functions) in a file in the plugins\personalfunctions\src directory and run the following:

        Add-OMPPlugin -Name 'personalfunctions'

    Doing this will automatically update your profile to include the personalfunctions plugin everytime you load OhMyPsh. If this is not what you want then run the following instead to just load it for this session:

        Add-OMPPlugin -Name 'personalfunctions' -Force -NoProfileUpdate

    EXAMPLE 2 - Run some task every 5th time you load OhMyPsh

    Perhaps you need your ego stroked a bit so you you decide to tell yourself how great you are every five times you load OhMyPsh. Easy stuff, first create your template plugin:

        New-OMPPlugin -Name 'egoboost'

    Next update the returned plugin.ps1 file with the following code:

        $Freq = 5
        $TotalRuns = Get-OMPProfileSetting -Name:OMPRunCount
        if (-not ($TotalRuns % $Freq)) {
            Write-Verbose "Total OMP run count is a multiple of the egoboost frequency setting ($Freq)"
            Write-Output "I'm Good Enough, I'm Smart Enough, and Doggone It, People Like Me!"
        }

    Test and then add the new plugin to your persistent session:

        Add-OMPPlugin -Name 'personalfunctions' -Force -NoProfileUpdate
        Add-OMPPlugin -Name 'personalfunctions' -Force

    Unload and reload the module a few times to be given your positive affirmation.

NOTE: Exported functions from plugins will not be shown with get-command -module OhMyPsh!
If you want to get a quick view of the functions that are in your session because of plugins then use the following command:

    Get-OMPPluginFunction

Easy Configuration
A fairly sane default configuration is provided out of the box with this module. You can see all current settings with
the following function:

    Get-OMPProfileSetting

You can easily modify all of these settings without ever having to open it in an editor. Use the Set-OMPProfileSetting function (which includes tab completion for all settings via the 'Name' Parameter BTW). These settings will instantly save to your persistent profile.

    EXAMPLE 1 - Enable verbose output when loading your module

        Set-OMPProfileSetting -Name:OMPDebug -Value:$false

    EXAMPLE 2 - Disable module auto cleanup (deletion of older version modules)

        Set-OMPProfileSetting -Name:AutoCleanOldModules -Value:$false

Themes
Themes are simply customized PSColor hash definitions and a prompt that get imported as a ps1 file. Set your theme with Set-OMPTheme.

    EXAMPLE 1 - Set the theme to 'norm'

        Set-OMPTheme norm

Further Information
The entire module is pure powershell and is hosted on github for your convenience. https://www.github.com/zloeber/OhMyPsh

'@ -replace '{{Profile}}', $Script:OMPProfileExportFile -replace '{{Plugins}}', ($Script:OMPState['PluginsLoaded'] -join ', ')

    Write-Output $Help
}