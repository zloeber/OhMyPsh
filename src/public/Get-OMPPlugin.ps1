function Get-OMPPlugin {
    <#
    .Synopsis
    Shows plugins and their load state.
    .DESCRIPTION
    Shows plugins and their load state.
    .PARAMETER Name
    The plugin name. If nothing is passed all plugins are listed.
    .EXAMPLE
    Get-OMPPlugin

    Shows all OhMyPsh plugins and if they are loaded or not.

    .EXAMPLE
    Get-OMPPlugin qod | select *

    Shows all the plugin properties of the qod plugin.
    .OUTPUTS
    OMP.PluginStatus
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    .NOTES
    Author: Zachary Loeber
    #>
    [CmdletBinding()]
    [OutputType('OMP.PluginStatus')]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [String]$Name
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."

        #Configure a default display set
        $defaultDisplaySet = 'Name','Loaded'

        #Create the default property display set
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    }
    process {
        $AllPlugins = @()
        Foreach ($PluginPath in $Script:OMPProfile['OMPPluginRootPaths']) {
            if ([string]::IsNullOrEmpty($Name)) {
                $SearchPath = $PluginPath
                (Get-ChildItem $SearchPath -Directory).FullName | ForEach-Object {
                    $AllPlugins += $_
                }
            }
            else {
                if (Test-Path (Join-Path $PluginPath $Name)) {
                    $AllPlugins = (Join-Path $PluginPath $Name)
                }
            }
        }

        if ($AllPlugins.Count -eq 0) {
            throw "Plugin not found in any path!"
        }
        $AllPlugins | ForEach-Object {
            $pluginmanifest = Join-Path $_ 'manifest.json'
            $manifest = $null
            if (Test-Path $pluginmanifest) {
                try {
                    Write-Verbose "$($FunctionName): Manifest file found - $pluginmanifest"
                    $manifest = Get-Content -Path $pluginmanifest -Raw | ConvertFrom-Json
                    Write-Verbose "$($FunctionName): Manifest file loaded."
                }
                catch {
                    Write-Verbose "$($FunctionName): Manifest file NOT loaded."
                }
            }
            $object = [pscustomobject]@{
                Name = Split-Path $_ -Leaf
                Loaded = if ($Script:OMPState['PluginsLoaded'] -contains (Split-Path $_ -Leaf)) {$true} else {$false}
                Path = $_
                Version = $manifest.Version
                Description = $manifest.Description
                Platform = $manifest.Platform
            }
            $object.PSTypeNames.Insert(0,'OMP.PluginStatus')
            $object | Add-Member MemberSet PSStandardMembers $PSStandardMembers

            $object
        }
    }
}