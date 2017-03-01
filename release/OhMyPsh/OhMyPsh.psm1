## Pre-Loaded Module code ##

param(
    [parameter(Position=0)]
    [string]$UserProfilePath
)

if (-not [string]::IsNullOrEmpty($UserProfilePath)) {
    if ((Test-Path -Path $UserProfilePath -PathType:Container)) {
        $Script:UserProfilePath = Resolve-Path -Path $UserProfilePath
    }
    else {
        throw "Invalid OhMyPsh profile path: $UserProfilePath"
    }
}
else {
        if ((Get-Variable 'PROFILE' -ErrorAction:SilentlyContinue) -eq $null) {
        throw 'No profile variable found!'
    }
    $Script:UserProfilePath = Split-Path $PROFILE
}

$OMPProfileExportFile = Join-Path $UserProfilePath '.OhMyPsh.config.json'
$OMPAliasExportFile =

if (-not $Script:ModulePath) {
    $ModulePath = Split-Path $script:MyInvocation.MyCommand.Path
}

# Backup some basic host settings
$Script:HostState = @{
    Title = $Host.UI.RawUI.WindowTitle
    Background = $Host.UI.RawUI.BackgroundColor
    Foreground = $Host.UI.RawUI.ForegroundColor
    Prompt = $function:prompt
    TabExpansion = $function:TabExpansion
    TabExpansion2 = $function:TabExpansion2
    PSDefaultParameterValues =  $Global:PSDefaultParameterValues.Clone()
    Aliases = Join-Path $UserProfilePath '.OhMyPsh.aliasbackup.ps1'
    Colors = @{
        BackgroundColor = $Host.UI.RawUI.BackgroundColor
        ForegroundColor = $Host.UI.RawUI.ForegroundColor
        ErrorForegroundColor = $Host.PrivateData.ErrorForegroundColor
        WarningForegroundColor = $Host.PrivateData.WarningForegroundColor
        DebugForegroundColor = $Host.PrivateData.DebugForegroundColor
        VerboseForegroundColor = $Host.PrivateData.VerboseForegroundColor
        ProgressForegroundColor = $Host.PrivateData.ProgressForegroundColor
        ErrorBackgroundColor = $Host.PrivateData.ErrorBackgroundColor
        WarningBackgroundColor  = $Host.PrivateData.WarningBackgroundColor
        DebugBackgroundColor = $Host.PrivateData.DebugBackgroundColor
        VerboseBackgroundColor = $Host.PrivateData.VerboseBackgroundColor
        ProgressBackgroundColor = $Host.PrivateData.ProgressBackgroundColor
    }
}

# Backup original aliases
Get-Alias | Where {($_.Options -split ',') -notcontains 'ReadOnly'} | Export-Alias -Path $Script:HostState['Aliases'] -As Script -Force

$Script:OMPConsole = @{
    WindowsTitlePrefix = $null
    WindowsTitlePostfix = $null
}
$Script:PromptColors = @{
    PromptForeground = [ConsoleColor]::Yellow
    ErrorForeground = [ConsoleColor]::DarkRed
    ErrorBackground = [ConsoleColor]::Black
    PromptBackground =  [ConsoleColor]::Black
}

## PRIVATE MODULE FUNCTIONS AND DATA ##

function Get-CallerPreference {
    <#
    .Synopsis
       Fetches "Preference" variable values from the caller's scope.
    .DESCRIPTION
       Script module functions do not automatically inherit their caller's variables, but they can be
       obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function
       for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState
       and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
    .PARAMETER Cmdlet
       The $PSCmdlet object from a script module Advanced Function.
    .PARAMETER SessionState
       The $ExecutionContext.SessionState object from a script module Advanced Function.  This is how the
       Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different
       script module.
    .PARAMETER Name
       Optional array of parameter names to retrieve from the caller's scope.  Default is to retrieve all
       Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
       This parameter may also specify names of variables that are not in the about_Preference_Variables
       help file, and the function will retrieve and set those as well.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Imports the default PowerShell preference variables from the caller into the local scope.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

       Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.
    .EXAMPLE
       'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Same as Example 2, but sends variable names to the Name parameter via pipeline input.
    .INPUTS
       String
    .OUTPUTS
       None.  This function does not produce pipeline output.
    .LINK
       about_Preference_Variables
    #>

    [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet' })]
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]$SessionState,

        [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline = $true)]
        [string[]]$Name
    )

    begin {
        $filterHash = @{}
    }
    
    process {
        if ($null -ne $Name)
        {
            foreach ($string in $Name)
            {
                $filterHash[$string] = $true
            }
        }
    }

    end {
        # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0

        $vars = @{
            'ErrorView' = $null
            'FormatEnumerationLimit' = $null
            'LogCommandHealthEvent' = $null
            'LogCommandLifecycleEvent' = $null
            'LogEngineHealthEvent' = $null
            'LogEngineLifecycleEvent' = $null
            'LogProviderHealthEvent' = $null
            'LogProviderLifecycleEvent' = $null
            'MaximumAliasCount' = $null
            'MaximumDriveCount' = $null
            'MaximumErrorCount' = $null
            'MaximumFunctionCount' = $null
            'MaximumHistoryCount' = $null
            'MaximumVariableCount' = $null
            'OFS' = $null
            'OutputEncoding' = $null
            'ProgressPreference' = $null
            'PSDefaultParameterValues' = $null
            'PSEmailServer' = $null
            'PSModuleAutoLoadingPreference' = $null
            'PSSessionApplicationName' = $null
            'PSSessionConfigurationName' = $null
            'PSSessionOption' = $null

            'ErrorActionPreference' = 'ErrorAction'
            'DebugPreference' = 'Debug'
            'ConfirmPreference' = 'Confirm'
            'WhatIfPreference' = 'WhatIf'
            'VerbosePreference' = 'Verbose'
            'WarningPreference' = 'WarningAction'
        }

        foreach ($entry in $vars.GetEnumerator()) {
            if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and
                ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name))) {
                
                $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)
                
                if ($null -ne $variable) {
                    if ($SessionState -eq $ExecutionContext.SessionState) {
                        Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                    }
                    else {
                        $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Filtered') {
            foreach ($varName in $filterHash.Keys) {
                if (-not $vars.ContainsKey($varName)) {
                    $variable = $Cmdlet.SessionState.PSVariable.Get($varName)
                
                    if ($null -ne $variable)
                    {
                        if ($SessionState -eq $ExecutionContext.SessionState)
                        {
                            Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                        }
                        else
                        {
                            $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                        }
                    }
                }
            }
        }
    }
}

Function Invoke-OMPPersonalFunction {
    <#
    .SYNOPSIS
        Dot sources a personal function file in the global context and tags it.
    .DESCRIPTION
        Dot sources a personal function file in the global context and tags it.
    .PARAMETER Path
        Path for the file to import.
    .PARAMETER Tag
        Tag to place on the function (in the form of a noteproperty).
    .EXAMPLE
        TBD
    .NOTES
        Author: Zachary Loeber


        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Path,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$Tag
    )

    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        Write-Verbose "Attempting to load the file $Path"
    }

    Process {
        if (Test-Path $Path) {
            $errmsg = $null

            # Load the script, replace any root level functions with its global equivalent. Then invoke.
            $script = (Get-Content $Path -Raw) -replace '^function\s+((?!global[:]|local[:]|script[:]|private[:])[\w-]+)', 'function Global:$1'
            try {
                $sb = [Scriptblock]::create(".{$script}")
                Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
                if (-not ([string]::IsNullOrEmpty($errmsg))) {
                    throw "Unable to load script file $Path"
                }
            }
            catch {
                throw "Unable to load script file $Path"
            }

            # Next look for any globally defined functions and tag them with a noteproperty to track
            ([System.Management.Automation.Language.Parser]::ParseInput($script, [ref]$null, [ref]$null)).FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | Foreach-Object {
                if (($_.Name).StartsWith('Global:')) {
                    $globalfunc = Get-ChildItem -Path "Function:\$($_.Name -replace 'Global:','')" -ErrorAction:SilentlyContinue
                    if ($GlobalFunc -ne $null) {
                        Write-Verbose "Function exported into the global session: $($_.Name -replace 'Global:','')"
                        try {
                            $globalfunc | Add-Member -MemberType 'NoteProperty' -Name 'ohmypsh' -Value $Tag -Force
                        }
                        catch {
                            # Do nothing as the member probably already existed.
                        }
                    }
                }
            }
        }
        else {
            throw "Invalid Path: $Path"
        }
    }
}

Function Read-HostContinue {
    param (
        [Parameter(Position=0)]
        [String]$PromptTitle = '',
        [Parameter(Position=1)]
        [string]$PromptQuestion = 'Continue?',
        [Parameter(Position=2)]
        [string]$YesDescription = 'Do this.',
        [Parameter(Position=3)]
        [string]$NoDescription = 'Do not do this.',
        [Parameter(Position=4)]
        [switch]$DefaultToNo,
        [Parameter(Position=5)]
        [switch]$Force
    )
    if ($Force) {
        (-not $DefaultToNo)
        return
    }
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", $YesDescription
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", $NoDescription

    if ($DefaultToNo) {
        $ConsolePrompt = [System.Management.Automation.Host.ChoiceDescription[]]($no,$yes)
    }
    else {
        $ConsolePrompt = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    }
    if (($host.ui.PromptForChoice($PromptTitle, $PromptQuestion , $ConsolePrompt, 0)) -eq 0) {
        $true
    }
    else {
        $false
    }
}

## PUBLIC MODULE FUNCTIONS AND DATA ##

Function Add-OMPAutoLoadModule {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Add-OMPAutoLoadModule.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name,
        [Parameter(Position = 1)]
        [switch]$NoProfileUpdate
    )
    try {
        Import-OMPModule -Name $Name
        $Script:OMPProfile['AutoLoadModule'] = @($Script:OMPProfile['AutoLoadModule'] + $Name | Sort-Object -Unique)
        if (-not $NoProfileUpdate) {
            Export-OMPProfile
        }
    }
    catch {
        throw "Unable to add module $($Name)"
    }
}


Function Add-OMPPersonalFunction {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Add-OMPPersonalFunction.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path,
        [Parameter(Position = 1)]
        [switch]$Recurse,
        [Parameter(Position = 2)]
        [switch]$NoProfileUpdate
    )
    $PathsAdded = $false
    if (Test-Path $Path) {
        if ($Recurse) {
            $Paths = @((Get-ChildItem -Path $Path -File -Filter '*.ps1').FullName)
        }
        else {
            $Paths = $($Path)
        }
        Foreach ($ScriptPath in $Paths) {
            Write-Verbose "Checking if the following is a valid candidate for being added: $ScriptPath"
            if ($Script:OMPProfile['PersonalFunctions'] -notcontains $ScriptPath){
                try {
                    Invoke-OMPPersonalFunction -Path $ScriptPath -Tag 'personalfunction'
                    $PathsAdded = $true
                    $Script:OMPProfile['PersonalFunctions'] += $ScriptPath
                }
                catch {
                    Write-Warning "Unable to load $ScriptPath"
                }
            }
        }
    }
    try {
        if ((-not $NoProfileUpdate) -and $PathsAdded) {
            Write-Verbose "Profile being updated"
            Export-OMPProfile
        }
    }
    catch {
        throw "Unable to add module $($Name)"
    }
}


Function Add-OMPPlugin {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Add-OMPPlugin.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name,
        [Parameter(Position = 1)]
        [switch]$Force,
        [Parameter(Position = 2)]
        [switch]$NoProfileUpdate
    )

    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        #$Verbosity = $PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent
        Write-Verbose "Attempting to load the plugin $Name"
    }

    Process {
        Foreach ($PPath in $Script:OMPProfile['OMPPluginRootPaths']) {
            if (Test-Path (Join-Path $PPath $Name)) {
                $PluginPath = $PPath
            }
        }
        if ($PluginPath -eq $null) {
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
            if (-not ([string]::IsNullOrEmpty($errmsg))) {
                Write-Warning "Unable to load plugin $Name"
                Write-Warning "Error: $($errmsg | Select *)"
                return
            }
            
            # Run preload plugin code
            $errmsg = $null
            $Preloadsb = [Scriptblock]::create(".{$Preload}")
            Invoke-Command -NoNewScope -ScriptBlock $Preloadsb -ErrorVariable errmsg 2>$null
            if (-not ([string]::IsNullOrEmpty($errmsg))) {
                Write-Warning "Unable to load plugin preload code for $Name"
                Write-Warning "Error: $($errmsg | Select *)"
                return
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
            if (-not ([string]::IsNullOrEmpty($errmsg))) {
                $errmsg
                Write-Warning "Unable to load plugin postload code for $Name"
                Write-Warning "Error: $($errmsg | Select *)"
                return
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


Function Add-OMPProfileSetting {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Add-OMPProfileSetting.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name,
        [Parameter(Position = 1)]
        $Value,
        [Parameter(Position = 2)]
        [switch]$NoProfileUpdate
    )
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $ExistingSettings = @(($Script:OMPProfile).Keys)
    Write-Verbose "Existing settings: $($ExistingSettings -join ', ')"
    if ($ExistingSettings -notcontains $Name) {
        try {
            $Script:OMPProfile[$Name] = $Value
        }
        catch {
            Write-Error "Unable to add profile setting $Name"
        }

        if (-not $NoProfileUpdate) {
            try {
                Export-OMPProfile
            }
            catch {
                throw "Unable to update or save the profile!"
            }
        }
    }
    else {
        Write-Output "$Name already exists as a setting. Doing nothing."
    }
}


Function Export-OMPProfile {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Export-OMPProfile.md
    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [string]$Path = $Script:OMPProfileExportFile
    )

    try {
        $Script:OMPProfile | ConvertTo-Json | Out-File $Path -Encoding:utf8 -Force
    }
    catch {
        throw "Unable to save $Path"
    }
}



function Get-OMPLoadedFunction {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Get-OMPLoadedFunction.md
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Name = '*'
    )
    Process {
        Get-ChildItem -Path "Function:\$Name" -Recurse | Where-Object { $_.ohmypsh -ne $null } | Select Name,ohmypsh
    }
}


function Get-OMPPlugin {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Get-OMPPlugin.md
    #>

    [CmdletBinding()]
    [OutputType('OMP.PluginStatus')]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [String]$Name
    )
    Begin {
        #Configure a default display set
        $defaultDisplaySet = 'Name','Loaded'

        #Create the default property display set
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    }
    Process {
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
            $object = [pscustomobject]@{
                Name = Split-Path $_ -Leaf
                Loaded = if ($Script:OMPState['PluginsLoaded'] -contains (Split-Path $_ -Leaf)) {$true} else {$false}
                Path = $_
            }
            $object.PSTypeNames.Insert(0,'OMP.PluginStatus')
            $object | Add-Member MemberSet PSStandardMembers $PSStandardMembers
            $object
        }
    }
}


Function Get-OMPProfilePath {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Get-OMPProfilePath.md
    #>
    [CmdletBinding()]
	param ()

    $Script:OMPProfileExportFile
}


Function Get-OMPProfileSetting {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Get-OMPProfileSetting.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateScript({
            (($Script:OMPProfile).Keys -contains $_ ) -or ([string]::IsNullOrEmpty($_))
        })]
        [String]$Name
    )
    Process {
        if ([string]::IsNullOrEmpty($Name)) {
            $Script:OMPProfile
        }
        else {
            $Script:OMPProfile[$Name]
        }
    }
}


Function Get-OMPPromptColor {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Get-OMPPromptColor.md
    #>
    [CmdletBinding()]
	param ()
    
    $Script:PromptColors
}


Function Get-OMPPSColor {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Get-OMPPSColor.md
    #>
    [CmdletBinding()]
	param ()
    
    $Script:PSColor
}


function Get-OMPTheme {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Get-OMPTheme.md
    #>

    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateScript({
            (@((Get-ChildItem (Join-Path $Script:ModulePath 'Themes') -File -Filter '*.ps1').Name | ForEach-Object {$_ -replace '.ps1',''}) -contains $_) -or ([string]::IsNullOrEmpty($_))
        })]
        [String]$Name
    )

    Process {
        if ([string]::IsNullOrEmpty($Name)) {
            $Themes = @((Get-ChildItem (Join-Path $Script:ModulePath 'Themes') -File -Filter '*.ps1').Name | ForEach-Object {$_ -replace '.ps1',''}) 
        }
        else {
            $Themes = @((Get-ChildItem (Join-Path $Script:ModulePath "Themes\$Name.ps1") -File -Filter '*.ps1').Name | ForEach-Object {$_ -replace '.ps1',''}) 
        }
        $Themes | ForEach-Object {
            New-Object -TypeName PSObject -Property @{
                'Name' = $_
                'Loaded' = if ($Script:OMPProfile['Theme'] -eq $_) {$true} else {$false}
            }
        }
    }
}


Function Import-OMPModule {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Import-OMPModule.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Name
    )
    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        $AllModules = @()
    }
    Process {
        $AllModules += $Name
    }
    End {
        Foreach ($Module in $AllModules) {
            if ((get-module $Module -ListAvailable) -eq $null) {
                if ($Script:OMPProfile['AutoInstallModules']) {
                    Write-Verbose "Attempting to install missing module: $($Module)"
                    try {
                        $null = Install-Module $Module -Scope:CurrentUser
                        Write-Verbose "Module Installed: $($Module)"
                    }
                    catch {
                        throw "Unable to find or install the following module requirement: $($Module)"
                    }
                }
                else {
                    throw "$($Module) was not found and automatic installation of modules is disabled in this profile!"
                }
            }

            # If we made it this far and the module isn't loaded, try to do so now
            if (-not (get-module $Module)) {
                Write-Verbose "Attempting to import module: $Module"
                Import-Module $Module -Global -force
            }
            else {
                Write-Verbose "$Module is already loaded"
                return
            }

            # check if it loaded properly
            if (-not (get-module $Module)) {
                throw "$($Module) was not able to load!"
            }
            else {
                Write-Verbose "Module Imported: $Module"
            }
        }
    }
}


Function Import-OMPProfile {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Import-OMPProfile.md
    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [string]$Path = $Script:OMPProfileExportFile
    )

    try {
        $LoadedProfile = Get-Content $Path | ConvertFrom-Json
    }
    catch {
        throw "Unable to load $Path"
    }

    $ProfileSettings = ($LoadedProfile | Get-Member -Type 'NoteProperty').Name
    ForEach ($Key in $ProfileSettings) {
        if (@($Script:OMPProfile.Keys) -contains $Key) {
            Write-Verbose "Updating profile setting '$key' from $Path"
            $Script:OMPProfile[$Key] = $LoadedProfile.$Key
        }
        else {
            Write-Verbose "Adding profile setting '$key' from $Path"
            ($Script:OMPProfile).$Key = $LoadedProfile.$Key
        }
    }
    $MissingSettings = @($Script:OMPProfile.Keys | Where {$ProfileSettings -notcontains $_})
    if ($MissingSettings.Count -gt 0) {
        Write-Verbose "There were $($MissingSettings.Count) settings missing from the saved profile. Re-exporting to bring profile up to date."
        try {
            Export-OMPProfile -Path $Script:OMPProfileExportFile
        }
        catch {
            throw "Unable to export profile to $($Script:OMPProfileExportFile)"
        }
    }
}



Function Invoke-OMPPluginShutdown {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Invoke-OMPPluginShutdown.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$Name
    )

    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        Write-Verbose "Attempting to shutdown the plugin $Name"
    }

    Process {
        Foreach ($Plugin in (Get-OMPPlugin -Name $Name | Where {$_.Loaded})) {
            $LoadScript = Join-Path $Plugin.Path "Load.ps1"
            $Shutdown = $null
            if (-not (Test-Path $LoadScript)) {
                Write-Error "Unable to find the plugin load file: $LoadScript"
                return
            }
            
            Write-Verbose "Executing plugin load script: $LoadScript"
            # pull in the entire load script
            $errmsg = $null
            $sb = [Scriptblock]::create(".{$(Get-Content -Path $LoadScript -Raw)}")
            Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
            if (-not ([string]::IsNullOrEmpty($errmsg))) {
                Write-Warning "Unable to load plugin $($Plugin.Name)"
                Write-Warning "Error: $($errmsg | Select *)"
                return
            }
            
            # Run shutdown plugin code
            $errmsg = $null
            if ($Shutdown -ne $null) {
                $Shutdownsb = [Scriptblock]::create(".{$Shutdown}")
                Invoke-Command -NoNewScope -ScriptBlock $Shutdownsb -ErrorVariable errmsg 2>$null
                if (-not ([string]::IsNullOrEmpty($errmsg))) {
                    Write-Warning "Unable to run shutdown plugin code for $($Plugin.Name)"
                    Write-Warning "Error: $($errmsg | Select *)"
                    return
                }
            }
        }
    }
}


Function New-OMPPlugin {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/New-OMPPlugin.md
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



Function Optimize-OMPProfile {
 <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Optimize-OMPProfile.md
    #>
    [CmdletBinding()]
    Param()
    $env:path = (@($env:path -split ';') + [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() | Sort-Object -Unique) -join ';'
    [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
        if (-not $_.location) {
            continue
        }
        $Name = Split-Path $_.location -leaf
        Write-Output "NGENing : $Name"
        ngen install $_.location | ForEach-Object {"`t$_"}
    }
}


Function Remove-OMPAutoLoadModule {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Remove-OMPAutoLoadModule.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name,
        [Parameter(Position = 1)]
        [switch]$NoProfileUpdate
    )
    try {
        Remove-OMPModule -Name $Name
        $Script:OMPProfile['AutoLoadModules'] = @($Script:OMPProfile['AutoLoadModules'] | Where-Object {$_ -ne $Name} | Sort-Object -Unique)
        if (-not $NoProfileUpdate) {
            Export-OMPProfile
        }
    }
    catch {
        throw "Unable to add module $($Name)"
    }
}


Function Remove-OMPModule {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Remove-OMPModule.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string[]]$Name,
        [Parameter(Position = 1)]
        [switch]$PluginSafe
    )
    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        $AllModules = @()
        $PluginSafeArg = @{}
        if ($PluginSafe) {
            $PluginSafeArg.PluginSafe = $true
        }

    }
    Process {
        $AllModules += (Get-Module $Name).Name
    }
    End {
        Foreach ($Module in $AllModules) {
            # Recursively remove dependant modules first...
            $ModulesDependOnMe = @(Get-Module | Where {$_.RequiredModules -contains $Module})
            if ($ModulesDependOnMe.Count -gt 0) {
                Write-Verbose "Found $($ModulesDependOnMe.Count) other modules dependant upon $Module"
                $ModulesDependOnMe | ForEach-Object {
                    Write-Verbose "Recursively attempting to remove $($_) first..."
                    Remove-OMPModule -Name $_ @PluginSafeArg
                }
            }

            # if pluginsafe removal then only remove modules new since OMP started and not in our autoload module list.
            if ($PluginSafe) {
                $WasAlreadyLoaded = ($Script:OMPState['ModulesAlreadyLoaded'] -contains $Module)
                $IsAutoLoaded = ($Script:OMPProfile['AutoLoadModules' -contains $Module])

                if (-not ($WasAlreadyLoaded -or $IsAutoLoaded)) {
                    try {
                        Write-Verbose "Attempting to remove module: $Module"
                        Remove-Module -Name $Module -Force
                    }
                    catch {
                        throw "Unable to remove module $($Name)"
                    }
                }
                else {
                    Write-Output "Refraining from unloading module as it is defined for autoloading in the profile or was loaded before OhMyPsh started."
                }
            }
            else {
                try {
                    Write-Verbose "Attempting to remove module: $Module"
                    Remove-Module -Name $Module -Force
                }
                catch {
                    throw "Unable to remove module $($Name)"
                }
            }
        }
    }
}


Function Remove-OMPPersonalFunction {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Remove-OMPPersonalFunction.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path,
        [Parameter(Position = 1)]
        [switch]$NoProfileUpdate
    )
    try {
        $Script:OMPProfile['PersonalFunctions'] = @($Script:OMPProfile['PersonalFunctions'] | Where-Object {$_ -ne $Path} | Sort-Object -Unique)
        if (-not $NoProfileUpdate) {
            Export-OMPProfile
        }
    }
    catch {
        throw "Unable to remove personal function path: $Path"
    }
}


Function Remove-OMPPlugin {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Remove-OMPPlugin.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name,
        [Parameter(Position = 1)]
        [switch]$Force,
        [Parameter(Position = 2)]
        [switch]$NoProfileUpdate
    )

    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        Write-Verbose "Attempting to load the plugin $Name"
    }

    Process {
        $LoadedPlugins = $Script:OMPState['PluginsLoaded']
        if (($LoadedPlugins -contains $Name) -or $Force) {
            $Unload = $null
            $PluginPath = (Get-OMPPlugin | Where {$_.Name -eq $Name}).Path
            $UnloadScript = Join-Path $PluginPath 'UnLoad.ps1'

            if (Test-Path $UnloadScript) {
                Write-Verbose "Executing plugin unload script: $UnloadScript"

                # pull in the unload definition
                $sb = [Scriptblock]::create(".{$(Get-Content -Path $UnloadScript -Raw)}")
                Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
                if (-not ([string]::IsNullOrEmpty($errmsg))) {
                    Write-Warning "Unable to unload plugin - $Name"
                    Write-Warning "Error: $($errmsg | Select *)"
                    throw
                }
            
                # Run unload plugin code
                $Unloadsb = [Scriptblock]::create(".{$Unload}")
                Invoke-Command -NoNewScope -ScriptBlock $Unloadsb -ErrorVariable errmsg 2>$null
                if (-not ([string]::IsNullOrEmpty($errmsg))) {
                    Write-Warning "Unable to unload plugin - $Name"
                    Write-Warning "Error: $($errmsg | Select *)"
                    throw
                }
            }
            else {
                Write-Verbose "No unload file found for plugin - $Name"
            }

            # If we made it this far then update our loaded plugins list to remove the plugin
            $Script:OMPState['PluginsLoaded'] = @($LoadedPlugins | Where-Object {$_ -ne $Name} | Sort-Object -Unique)

            if (-not $NoProfileUpdate) {
                try {
                    $Script:OMPProfile['Plugins'] = @($Script:OMPProfile['Plugins'] | Where-Object {$_ -ne $Name} | Sort-Object -Unique)
                    Export-OMPProfile
                }
                catch {
                    throw "Unable to update or save the profile!"
                }
            }
        }
        else {
            Write-Output "$Name is not loaded in this session. Use the -Force parameter to try to unload it regardless."
        }
    }
}


Function Remove-OMPProfileSetting {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Remove-OMPProfileSetting.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name,
        [Parameter(Position = 1)]
        [switch]$NoProfileUpdate
    )
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $ExistingSettings = @(($Script:OMPProfile).Keys)

    if (($ExistingSettings -contains $Name) -and ($Script:OMPProfileCoreSettings -notcontains $Name)) {
        try {
            ($Script:OMPProfile).Remove($Name)
        }
        catch {
            Write-Error "Unable to remove profile setting $Name"
        }

        if (-not $NoProfileUpdate) {
            try {
                Export-OMPProfile
            }
            catch {
                throw "Unable to update or save the profile!"
            }
        }
    }
    else {
        Write-Output "$Name either doesn't exist or is a core profile property"
    }
}


Function Restore-OMPOriginalAlias {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Restore-OMPOriginalAlias.md
    #>
    [CmdletBinding()]
	param ()
    # I cannot figure out a way to import these automatically back into the users session when the module unloads
    # so for now tell the user how to do so themselves if so desired.
    $Path = $Script:HostState['Aliases']
    if ((Test-Path $Path)) {
        Write-Output ''
        Write-Output "Original aliases stored in $Path"
        Write-Output "To restore these into your session run the following: "
        Write-Output ''
        Write-Output ". $Path"
        Write-Output ''
    }
}


Function Restore-OMPOriginalConsole {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Restore-OMPOriginalConsole.md
    #>
    [CmdletBinding()]
	param ()
    Write-Output 'Restoring original console title'
    $Global:Host.UI.RawUI.WindowTitle = $Script:HostState['Title']

    Write-Output 'Restoring original console colors (this does not include psreadline configurations)'
    $Global:Host.UI.RawUI.ForegroundColor = $Script:HostState['Colors']['ForegroundColor']
    $Global:Host.UI.RawUI.BackgroundColor = $Script:HostState['Colors']['BackgroundColor']

    # Host Foreground
    $Global:Host.PrivateData.ErrorForegroundColor = $Script:HostState['Colors']['ErrorForegroundColor']
    $Global:Host.PrivateData.WarningForegroundColor = $Script:HostState['Colors']['WarningForegroundColor']
    $Global:Host.PrivateData.DebugForegroundColor = $Script:HostState['Colors']['DebugForegroundColor']
    $Global:Host.PrivateData.VerboseForegroundColor = $Script:HostState['Colors']['VerboseForegroundColor']
    $Global:Host.PrivateData.ProgressForegroundColor = $Script:HostState['Colors']['ProgressForegroundColor']

    # Host Background
    $Global:Host.PrivateData.ErrorBackgroundColor = $Script:HostState['Colors']['ErrorBackgroundColor']
    $Global:Host.PrivateData.WarningBackgroundColor = $Script:HostState['Colors']['WarningBackgroundColor']
    $Global:Host.PrivateData.DebugBackgroundColor = $Script:HostState['Colors']['DebugBackgroundColor']
    $Global:Host.PrivateData.VerboseBackgroundColor = $Script:HostState['Colors']['VerboseBackgroundColor']
    $Global:Host.PrivateData.ProgressBackgroundColor = $Script:HostState['Colors']['ProgressBackgroundColor']
}


Function Restore-OMPOriginalPrompt {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Restore-OMPOriginalPrompt.md
    #>
    [CmdletBinding()]
	param ()
    #if ($null -ne $Script:OldPrompt) {
        Write-Output 'Restoring original Prompt function'
        Set-Item Function:\prompt $Script:HostState['Prompt']
    #}
}


Function Restore-OMPOriginalPSDefaultParameter {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Restore-OMPOriginalPSDefaultParameter.md
    #>
    [CmdletBinding()]
	param ()
    Write-Output 'Restoring original PSDefaultParameters variable'
    $Global:PSDefaultParameterValues = $Script:HostState['PSDefaultParameterValues'].Clone()

}


Function Restore-OMPOriginalTabCompletion {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Restore-OMPOriginalTabCompletion.md
    #>
    [CmdletBinding()]
	param ()
#    if ($null -ne $Script:OldTabExpansion) {
        Write-Output 'Restoring original TabExpansion function'
        Set-Item function:\TabExpansion $Script:HostState['TabExpansion']
#    }
#    if ($null -ne $Script:OldTabExpansion2) {
        Write-Output 'Restoring original TabExpansion2 function'
        Set-Item function:\TabExpansion2 $Script:HostState['TabExpansion2']
#    }
}


Function Set-OMPProfileSetting {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Set-OMPProfileSetting.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name,
        [Parameter(Position = 1, Mandatory = $true)]
        $Value
    )
    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        Write-Verbose "Attempting to update profile setting: $Name"
    }
    Process {
        try {
            $Script:OMPProfile[$Name] = $Value
        }
        catch {
            throw "Unable to update profile setting $Name"
        }
    }
    End {
        try {
                Export-OMPProfile
        }
        catch {
            throw "Unable to update or save the profile!"
        }
    }
}


Function Set-OMPTheme {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Set-OMPTheme.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0)]
        [String]$Name = $Script:OMPProfile['Theme'],
        [Parameter(Position = 1)]
        [switch]$NoProfileUpdate
    )
    $Verbosity = if ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent) {' -Verbose'} else {''}
    if ([string]::IsNullOrEmpty($Name)) {
        Write-Output "No theme specified, restoring the original PowerShell prompt"
        Restore-OMPOriginalPrompt
        return
    }
    $ThemeScriptPath = (Join-Path $Script:ModulePath "themes\$Name.ps1")
    if (Test-Path $ThemeScriptPath) {
        Write-Verbose "Loading theme file: $ThemeScriptPath"
        $script = (Get-Content $ThemeScriptPath -Raw)
        try {
            $sb = [Scriptblock]::create(".{$script}")
            Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
            if (-not ([string]::IsNullOrEmpty($errmsg))) {
                throw "Unable to load theme file $ThemeScriptPath"
            }
        }
        catch {
            throw "Unable to load theme file $ThemeScriptPath"
        }
        if (-not $NoProfileUpdate) {
            $Script:OMPProfile['Theme'] = $Name
        }
    }
    else {
        Throw "Theme with the name $Name was not found!"
    }
}


Function Set-OMPWindowTitle {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Set-OMPWindowTitle.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Title
    )
    $Global:Host.UI.RawUI.WindowTitle = $Title
}


function Show-OMPHelp {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Show-OMPHelp.md
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
Plugins are dot sourced files that run scripts or import functions/variables/aliases into your session in a seamless manner. These are
extremely powerful and versitile with only a nominal amount of effort to create and deploy. Here are a few examples on what you might
do with them:

    EXAMPLE 1 - Keep a dumping ground of your personal 'One-off' script functions.
    
    With this module you can quickly load one off functions in your profile every time you start this module. This is common for
    many users that simply need to use a particular function over and over but don't have a need to turn them into full blown modules.
    Simply define the function in the global scope like so:
        function Global:MyFunction {
            Write-Output 'Test'
        }
    
    Then save the function (or functions) in a file in the plugins\personalfunctions\src directory and run the following:
    
        Add-OMPPlugin -Name 'personalfunctions' -Force

    Doing this will automatically update your profile to include the personalfunctions plugin everytime you load OhMyPsh. If
    this is not what you want then run the following instead to just load it for this session:
    
        Add-OMPPlugin -Name 'personalfunctions' -Force -NoProfileUpdate

    EXAMPLE 2 - Run some task every 5th time you load OhMyPsh

    Perhaps you need your ego stroked a bit so you you decide to tell yourself how great you are every five times you load OhMyPsh. 
    Easy stuff, first create your template plugin:

        New-OMPPlugin -Name 'egoboost'
    
    Next update the returned plugin.ps1 file path with the following code:

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

NOTE! Exported functions from plugins will not be shown with get-command -module OhMyPsh. 
If you want to get a quick view of the functions that are in your session because of plugins then use the following command: 

    Get-OMPPluginFunction

Easy Configuration
A fairly sane default configuration is provided out of the box with this module. You can see all current settings with
the following function:
    
    Get-OMPProfileSetting

You can easily modify all of these settings without ever having to open it in an editor. Use the Set-OMPProfileSetting function
(which includes tab completion for all settings via the 'Name' Parameter BTW). These settings will instantly save to
your persistent profile.

    EXAMPLE 1 - Enable verbose output when loading your module
        
        Set-OMPProfileSetting -Name:OMPDebug -Value:$false

    EXAMPLE 2 - Disable module auto cleanup (deletion of older version modules)
        
        Set-OMPProfileSetting -Name:AutoCleanOldModules -Value:$false

Themes
Themes are simply customized PSColor hash definitions and a prompt that get imported as a ps1 file. Set your theme 
with Set-OMPTheme.

    EXAMPLE 1 - Set the theme to 'norm'

        Set-OMPTheme -Name:norm

Further Information
The entire module is pure powershell and is hosted on github for your convenience. https://www.github.com/zloeber/OhMyPsh

'@ -replace '{{Profile}}', $Script:OMPProfileExportFile -replace '{{Plugins}}', ($Script:OMPState['PluginsLoaded'] -join ', ')

    Write-Output $Help
}


function Show-OMPStatus {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Show-OMPStatus.md
    #>

    [CmdletBinding()]
    param ()

    $Status = @'
Current OhMyPsh Profile: {{Profile}}
Loaded Plugins: {{Plugins}}
'@ -replace '{{Profile}}', $Script:OMPProfileExportFile -replace '{{Plugins}}', ($Script:OMPState['PluginsLoaded'] -join ', ')

    Write-Output $Status
}


Function Test-OMPProfileSetting {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://www.github.com/zloeber/OhMyPsh/tree/master/release/0.0.1/docs/Test-OMPProfileSetting.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [String]$Name
    )
    Process {
        if (($Script:OMPProfile).Keys -contains $_ ) {
            $true
        }
        else {
            $false
        }
    }
}



## Post-Load Module code ##

# These are core settings which we will not allowed to get removed
$Script:OMPProfileCoreSettings = @(
    'AutoLoadModules',
    'AutoInstallModules',
    'Plugins',
    'PersonalFunctions',
    'Theme',
    'UnloadModulesOnExit',
    'OMPRunCount',
    'OMPPluginRootPaths',
    'OMPDebug'
)

<#
    Fill out each of the setting hash entries with some sensible defaults.
    This is the master template for user profile settings. Once the module runs once these
    settings are effectively ignored and should be managed via the exported functions instead.
#>
$Script:OMPProfile = @{
    # Load these modules with your OMP profile
    AutoLoadModules = @()
    # Download modules if missing?
    AutoInstallModules = $true
    # Which plugins would you like to load?
    Plugins = @()
    # Personal functions are like plugins but less structured
    PersonalFunctions = @()
    # Theme
    Theme = $null
    # If this is true we will attempt to unload any modules that weren't already loaded when we started
    UnloadModulesOnExit = $true
    # Used to display first time help or just keep a run of how much you love this module
    OMPRunCount = 0
    # Plugins can be located in many locations, this is the list of paths they may reside in
    OMPPluginRootPaths = @((Join-Path $ModulePath "plugins"))
    # Use this to see additional output when loading the module
    OMPDebug = $false
}

# Load any persistent data (overrides anything in OMPSettings if the hash element exists)
if ((Test-Path $OMPProfileExportFile)) {
    try {
        Import-OMPProfile -Path $OMPProfileExportFile
    }
    catch {
        throw "Unable to load the OMP profile: $OMPProfileExportFile"
    }
}

$VerbosityFlag = @{}
if ($Script:OMPProfile['OMPDebug']) {
    $VerbosityFlag.Verbose = $true
    $Script:OldVerbosePreference = $VerbosePreference
    $VerbosePreference = "Continue"
}

# We need to keep some state information outside of the profile. This is the hash
# used for this purpose.
$OMPState = @{
    PluginsLoaded = @()
    ModulesAlreadyLoaded = @((Get-Module).Name)
}

<#
    Perform profile processing, this is where all the fun begins...
#>

# 1. Load any specified autoload modules
$Script:OMPProfile['AutoLoadModules'] | Import-OMPModule @VerbosityFlag

# 2. Now the personal functions
$Script:OMPProfile['PersonalFunctions'] | Foreach-Object {
    try {
        Invoke-OMPPersonalFunction -Path $_ -Tag 'personalfunction'
    }
    catch {}
}

# 3. Now the plugins
Write-Verbose 'Loading Plugins:'
Foreach ($Plugin in ($Script:OMPProfile['Plugins'] | Sort-Object)) {
    Write-Verbose "Attempting to load plugin $Plugin"
    try {
        Add-OMPPlugin -Name $Plugin -NoProfileUpdate @VerbosityFlag
        Write-Verbose "Plugin Loaded: $Plugin"
    }
    catch {
        Write-Warning "Unable to load the following plugin: $($_)"
    }
}

# 4. Next the theme
try {
    $Theme = $Script:OMPProfile['Theme']
    Set-OMPTheme -Name $Theme -NoProfileUpdate
    Write-Verbose "Theme Loaded: $($Theme)"
}
catch {
    throw "Unable to load the following theme: $($Theme)"
}

# 5. If we made it this far then we can bump up our run count by 1, save,
#     and continue processing items that rely upon this number
$Script:OMPProfile['OMPRunCount'] += 1
Export-OMPProfile -Path $OMPProfileExportFile

########################################################################
# Action to take if the module is removed
$ExecutionContext.SessionState.Module.OnRemove = {
    # Any functions loaded as plugins will get removed from the pssession
    Write-Output "Removing plugin or other dot sourced functions performed within OhMyPsh.."
    Get-ChildItem -Path Function:\ -Recurse | Where-Object { $_.ohmypsh -ne $null } | Remove-Item -Force

    # Run any plugin shutdown code blocks
    Write-Output "Processing OhMyPsh plugin shutdown scriptblocks"
    Invoke-OMPPluginShutdown

    # Remove any newly loaded modules since we started (if enabled)
    if ($Script:OMPProfile['UnloadModulesOnExit']) {
        Write-Output "Removing any modules loaded since OhMyPsh started"
        Get-Module | Where-Object {$OMPState['ModulesAlreadyLoaded'] -notcontains $_.Name} | Foreach-Object {
            if ($_.Name -ne 'OhMyPsh') {
                Write-Output "    Module being removed from this session: $($_.Name)"
                Remove-Module -Name $_.Name -Force
            }
        }
    }
    # Restore prompts, tabcompletion, aliases, and console settings
    Restore-OMPOriginalPrompt
    Restore-OMPOriginalTabCompletion
    Restore-OMPOriginalPSDefaultParameter
    Restore-OMPOriginalAlias
    Restore-OMPOriginalConsole
}


$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {
    # Action to take if the whole pssession is killed
    # Run any plugin shutdown code blocks at the very least.
    Invoke-OMPPluginShutdown
}

if ($Script:OMPProfile['OMPDebug']) {
    $VerbosityFlag = @{}
    $VerbosePreference = $Script:OldVerbosePreference
}


