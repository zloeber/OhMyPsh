Function Add-OMPPlugin {
    <#
    .SYNOPSIS
    Dot sources a plugin
    .DESCRIPTION
    Dot sources a plugin and enables it for your profile.
    .PARAMETER Force
    If the plugin is already loaded use this to force load it again.
    .PARAMETER NoProfileUpdate
    Skip updating the profile
    .PARAMETER UpdateConfig
    Force an update of the plugin configuration. If a config scriptblock is passed then that will be used as the update. Otherwise if a config scriptblock is found in the plugin that will be used instead. This is an advanced parameter that should rarely need to be used.
    .PARAMETER DebugOutput
    Show some additional output for debugging purposes.
    .EXAMPLE
    PS> Add-OMPPlugin -Name 'o365'

    .EXAMPLE
    PS> 'chocolatey','o365' | Add-OMPPlugin
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://github.com/zloeber/ohmypsh
    #>
    [CmdletBinding()]
	param (
        [Parameter()]
        [switch]$Force,
        [Parameter()]
        [switch]$NoProfileUpdate,
        [Parameter()]
        [switch]$UpdateConfig,
        [Parameter()]
        [switch]$DebugOutput
    )
    dynamicparam {
        # Create dictionary
        $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ValidPlugins = @()

        Foreach ($PPath in $Script:OMPProfile['OMPPluginRootPaths']) {
            $ValidPlugins += (Get-ChildItem $PPath -Directory).Name
        }

        $ValidPlugins = $ValidPlugins | Sort-Object | Select-Object -Unique

        $NewParamSettings = @{
            Name = 'Name'
            Position = 0
            Type = 'string'
            ValidateSet = $ValidPlugins
            HelpMessage = "The plugin to add to your profile and optionally load."
            ValueFromPipeline = $true
            ValueFromPipelineByPropertyName = $true
        }

        # Add new dynamic parameter to dictionary
        New-DynamicParameter @NewParamSettings -Dictionary $DynamicParameters

        # Return dictionary with dynamic parameters
        $DynamicParameters
    }
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }

    Process {
        # Pull in the dynamic parameters first
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters
        $PluginPath = $null
        Foreach ($PPath in $Script:OMPProfile['OMPPluginRootPaths']) {
            if (Test-Path (Join-Path $PPath $Name)) {
                if ($null -eq $PluginPath) {
                    Write-Verbose "$($FunctionName): Loading the plugin found in $PPath"
                    $PluginPath = $PPath
                }
                else {
                    Write-Warning "$($FunctionName): More than one root plugin folder paths contain the plugin named $Name, ignoring the plugin found in $PPath"
                }
            }
        }
        if ($null -eq $PluginPath) {
            Write-Warning "Unable to locate $Name in any plugin paths!"
            return
        }

        $LoadedPlugins = $Script:OMPState['PluginsLoaded']
        if (($LoadedPlugins -notcontains $Name) -or $Force) {
            $Preload = $null
            $PostLoad = $null
            $LoadScript = Join-Path $PluginPath "$Name\Load.ps1"

            if (-not (Test-Path $LoadScript)) {
                Write-Error "Unable to find the plugin load file: $LoadScript"
            }
            Write-Verbose "Executing plugin load script: $LoadScript"

            # pull in the preload and postload definitions
            $errmsg = $null
            $sb = [Scriptblock]::create(".{$(Get-Content -Path $LoadScript -Raw)}")
            Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
            if (-not ([string]::IsNullOrEmpty($errmsg)) -and $DebugOutput) {
                Write-Warning "Unable to load plugin $Name"
                Write-Warning "Error: $($errmsg | Select *)"
                if (-not $Force) {
                    return
                }
            }

            # Run preload plugin code
            $errmsg = $null
            $Preloadsb = [Scriptblock]::create(".{$Preload}")
            Invoke-Command -NoNewScope -ScriptBlock $Preloadsb -ErrorVariable errmsg 2>$null
            if (-not ([string]::IsNullOrEmpty($errmsg)) -and $Debug) {
                Write-Warning "Unable to load plugin preload code for $Name"
                Write-Warning "Error: $($errmsg | Select *)"
                if (-not $Force) {
                    return
                }
            }

            # Dot source any file in the plugin src directory of this plugin and track global functions
            $FullPluginSrcPath = Join-Path $PluginPath "$Name\src"
            Write-Verbose "Plugin $Name source file repo is $FullPluginSrcPath"

            Get-ChildItem -Path $FullPluginSrcPath -Recurse -Filter "*.ps1" -File | Sort-Object Name | ForEach-Object {
                Write-Verbose "Dot sourcing plugin script file: $($_.Name)"
                # First dot source the ps1
                . $_.FullName

                # Next look for any globally defined functions and tag them with a noteproperty to track
                ([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | Foreach-Object {
                    if (($_.Name).StartsWith('Global:')) {
                        $globalfunc = Get-ChildItem -Path "Function:\$($_.Name -replace 'Global:','')"
                        if ($GlobalFunc -ne $null) {
                            Write-Verbose "Plugin function exported into the global session: $($_.Name -replace 'Global:','')"
                            $globalfunc | Add-Member -MemberType 'NoteProperty' -Name 'ohmypsh' -Value "$Name" -Force
                        }
                    }
                }
            }

            # Run postload plugin code
            $errmsg = $null
            $Postloadsb = [Scriptblock]::create(".{$Postload}")
            Invoke-Command -NoNewScope -ScriptBlock $Postloadsb -ErrorVariable errmsg 2>$null
            if (-not ([string]::IsNullOrEmpty($errmsg)) -and $Debug) {
                $errmsg
                Write-Warning "Unable to load plugin postload code for $Name"
                Write-Warning "Error: $($errmsg | Select *)"
                if (-not $Force) {
                    return
                }
            }

            # Finally run any config plugin code
            if ((Test-OMPProfileSetting -Name "pluginconfig_$Name") -and (-not $UpdateConfig)) {
                $Config = Get-OMPProfileSetting -Name "pluginconfig_$Name"
            }
            else {
                # If not already in the profile config add the plugin config variable
                if (Test-OMPProfileSetting -Name "pluginconfig_$Name") {
                    Set-OMPProfileSetting -Name "pluginconfig_$Name" -Value ([string]$Config)
                }
                else {
                    Add-OMPProfileSetting -Name "pluginconfig_$Name" -Value ([string]$Config)
                }
            }
            $errmsg = $null
            $Configsb = [Scriptblock]::create(".{$Config}")
            Invoke-Command -NoNewScope -ScriptBlock $Configsb -ErrorVariable errmsg 2>$null
            if (-not ([string]::IsNullOrEmpty($errmsg)) -and $Debug) {
                $errmsg
                Write-Warning "Unable to load plugin configuration code for $Name"
                Write-Warning "Error: $($errmsg | Select *)"
                if (-not $Force) {
                    return
                }
            }

            # If we made it this far then update our loaded plugins list
            $LoadedPlugins += $Name
            $Script:OMPState['PluginsLoaded'] = @($LoadedPlugins | Sort-Object -Unique)

            if (-not $NoProfileUpdate) {
                try {
                    # update the profile plugins list as well
                    $ProfPlugins = $Script:OMPProfile['Plugins']
                    $ProfPlugins += $Name
                    $Script:OMPProfile['Plugins'] = @($ProfPlugins | Sort-Object -Unique)
                    Export-OMPProfile
                }
                catch {
                    throw "Unable to update or save the profile!"
                }
            }
        }
        else {
            Write-Output "$Name already is loaded in this session. Use the -Force parameter to load it again anyways.."
        }
    }
}