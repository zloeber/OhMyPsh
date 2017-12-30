Function New-OMPPluginManifest {
    <#
    .SYNOPSIS
    Creates a new OMP Plugin manifest file.
    .DESCRIPTION
    Creates a new OMP Plugin manifest file.
    .PARAMETER Name
    Name of the plugin
    .PARAMETER Path
    Path of the manifest file. The default path is the plugin folder in the module directory.
    .PARAMETER Version
    Version of the plugin. Defaults to 0.0.1.
    .PARAMETER Description
    Plugin description for the manifest file.
    .EXAMPLE
    PS> New-OMPPluginManifest -Name 'mygreatplugin' -Version '0.0.1' -Description 'My great plugin'

    Creates 'mygreatplugin' manifest file in the mygreatplugin directory of the current and displays the full path to the created plugin.

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
        [string]$Path,
        [Parameter()]
        [string]$Version = '0.0.1',
        [Parameter()]
        [string]$Description = ''

    )
    if ($script:ThisModuleLoaded -eq $true) {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    }
    $FunctionName = $MyInvocation.MyCommand.Name
    Write-Verbose "$($FunctionName): Begin."

    if ([string]::IsNullOrEmpty($Path)) {
        $ManifestFile = Join-Path $Script:ModulePath "plugins\$Name\manifest.json"
    }
    else {
        if (Test-Path $Path) {
            if (-not $Path.EndsWith('manifest.json')) {
                $ManifestFile = Join-Path $Path 'manifest.json'
            }
            else {
                $ManifestFile = $Path
            }
        }
        else {
            throw "$Path does not exist!"
        }
    }

    Write-Verbose "$($FunctionName): Manifest file to output = $Manifestfile"

    try {
        [psobject]@{
            Name = $Name
            Version = $Version
            Description = $Description
        } | ConvertTo-Json | Out-File $ManifestFile -Encoding:utf8
    }
    catch {
        throw
    }

}