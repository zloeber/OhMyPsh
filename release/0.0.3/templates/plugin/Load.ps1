<#
    NOTE: In either of the sections below you have the following variables at your disposal

        $PluginPath = The current path of your plugin minus the name (ie. C:\temp\)
        $Name = The name of your plugin folder. (ie. myplugin)

    So the full path to where this file is saved would be:

        Join-Path $PluginPath $Name
#>
$PreLoad = {
    <#
        Load any requirements here. Any modules should be loaded via Import-OMPModule
        to ensure they adhere to the profile settings for module auto installation.

        Example:
            Import-OMPModule 'Posh-Git'

        You should put any functions you want exported in a separate ps1 file (of any name) in the src
        directory. If you want the function to be available in the OhMyPsh session then you will need to
        create it in a global scope.
    #>
}

$PostLoad = {
    <#
        Anything else you may want to do after the plugin loads (Write a message to the screen, create aliases, et cetera)
        The only rule is that anything you want available in the user session must be scoped globally or it will
        never see the outside of this module scope!

        Note, anything you create here should be gracefully removed in the respective 'Unload.ps1' file in this
        plugin directory. If you don't adhere to this rule your plugin will not be considered for this project.
        You don't have to worry about removing any globally scoped functions, the template Unload.ps1 code will
        do that and the module unload code will also remove them from memory upon being unloaded.

        Example 1:
            Set-Alias -Name ll -Value Get-ChildItem -option AllScope -Scope Global

            Sets an alias for Get-ChildItem called 'll' in the global scope
    #>
}

$Config = {
    <#
        This gets run after the PostLoad scriptblock. At first run it will be stored in
        the profile path as the configuration to be used for this plugin moving forward.

        The config scriptblock is a way to maintain plugin settings that persist through
        an OhMyPsh upgrade.
    #>
}
$Shutdown = {
    <#
        Put anything here you need to run if OhMyPsh is unloaded or the console session is killed.
        If you have a profile variable that needs to be updated for the next first run of your plugin this
        is the place to put it.

        Example:
            Set-OMPProfileSetting -Name 'PSReadlineHistoryLoaded' -Value $false
            Export-OMPProfile
    #>
}

$Unload = {
    <#
        Be nice and be modular please, unload any other profile settings or loaded modules you may
        have introduced with your plugin.

        *NOTE* Any 'global:<functionname> items will have already been automatically removed by
        OhMyPsh at this point so you don't have to worry about those!
    #>
}