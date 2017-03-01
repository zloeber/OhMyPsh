Function New-OMPPlugin {
    <#
    .SYNOPSIS
        Creates a new OMP Plugin template.
    .DESCRIPTION
        Creates a new OMP Plugin template.
    .PARAMETER Name
        Name of the plugin
    .EXAMPLE
        PS> New-OMPPlugin -Name 'mygreatplugin'

        Creates 'mygreatplugin' in the plugins directory and displays the full path to the created plugin.

    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name
    )

    $TemplatePath = Join-Path $Script:ModulePath 'templates\plugin'
    $PluginDestPath = Join-Path $Script:ModulePath "plugins\$Name"

    if (Test-Path $TemplatePath) {
        if (-not (Test-Path $PluginDestPath)) {
            $null = Copy-Item -Path $TemplatePath -Destination $PluginDestPath -Recurse
            Write-Output "The following plugin template has been created: $PluginDestPath"
            Write-Output "Modify the $PluginDestPath\src\Plugin.ps1 file to suit your needs."
            Write-Output "When ready to do so, test your plugin with Add-OMPPlugin -Name $Name -NoProfileUpdate"
        }
        else {
            Write-Error "The plugin name already exists: $PluginDestPath"    
        }
    }
    else {
        Write-Error "The source plugin template path doesn't exist: $TemplatePath"
    }
}