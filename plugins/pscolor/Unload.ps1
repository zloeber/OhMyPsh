<#
    NOTE: In the sections below you have the following variables at your disposal

        $PluginPath = The current path of your plugin minus the name (ie. C:\temp\)
        $Name = The name of your plugin folder. (ie. myplugin)

    So the full path to where this file is saved would be:

        Join-Path $PluginPath $Name
#>
$Unload = {
    <#
        Be nice and be modular please, unload any other createe items you may have created in this plugin
        using this scriptblock.

        *NOTE* Any 'global:<functionname> items will have already been automatically removed by
        OhMyPsh at this point so you don't have to worry about those!
    #>
}