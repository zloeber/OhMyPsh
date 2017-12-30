Function New-OMPPlugin {
    <#
    .SYNOPSIS
    Creates a new OMP Plugin template.
    .DESCRIPTION
    Creates a new OMP Plugin template.
    .PARAMETER Name
    Name of the plugin
    .PARAMETER Path
    Path of the plugin. The default path is the plugin folder in the module directory.
    .EXAMPLE
    PS> New-OMPPlugin -Name 'mygreatplugin'

    Creates 'mygreatplugin' in the plugins directory and displays the full path to the created plugin.

    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter()]
        [string]$Path
    )
    if ($script:ThisModuleLoaded -eq $true) {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    }
    $FunctionName = $MyInvocation.MyCommand.Name
    Write-Verbose "$($FunctionName): Begin."

    $TemplatePath = Join-Path $Script:ModulePath 'templates\plugin'
    if ([string]::IsNullOrEmpty($Path)) {
        $PluginDestPath = Join-Path $Script:ModulePath "plugins\$Name"
    }
    else {
        if (Test-Path $Path) {
            $PluginDestPath = Join-Path $Path $Name

            if ((Get-OMPProfileSetting).OMPPluginRootPaths -notcontains $Path) {
                Write-Warning "$($FunctionName): $Path exists but is not in the OMPPluginRootPaths list for your profile. This plugin will be created regardless but will not be usable."
            }
        }
        else {
            throw "$Path does not exist!"
        }
    }

    Write-Verbose "$($FunctionName): New Plugin Path = $PluginDestPath"
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