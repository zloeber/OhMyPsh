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
$IsConEmuConsole = if ($null -ne $env:ConEmuANSI) {$true} else {$false}

# Backup some basic host settings. these never get updated and are used for restore purposes.
$Script:HostState = @{
    Title = $Host.UI.RawUI.WindowTitle
    Background = $Host.UI.RawUI.BackgroundColor
    Foreground = $Host.UI.RawUI.ForegroundColor
    Prompt = $function:prompt
    TabExpansion = $function:TabExpansion
    TabExpansion2 = $function:TabExpansion2
    PSDefaultParameterValues =  $Global:PSDefaultParameterValues.Clone()
    Aliases = Join-Path $UserProfilePath '.OhMyPsh.aliasbackup.ps1'
    Modules = (Get-Module).Name
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

if (get-module psreadline) {
    $Script:PSReadlineState = Get-PSReadlineOption
}
else {
    $Script:PSReadlineState = $null
}

if (-not $Script:ModulePath) {
    $ModulePath = Split-Path $script:MyInvocation.MyCommand.Path
}

# Backup original aliases
Get-Alias | Where {($_.Options -split ',') -notcontains 'ReadOnly'} | Export-Alias -Path $Script:HostState['Aliases'] -As Script -Force

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
        Dot sources a personal function file in the global context and tags it to ohmypsh.
    .DESCRIPTION
        Dot sources a personal function file in the global context and tags it to ohmypsh.
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

function New-DynamicParameter {
    <#
    .SYNOPSIS
    Helper function to simplify creating dynamic parameters

    .DESCRIPTION
    Helper function to simplify creating dynamic parameters.

    Example use cases:
        Include parameters only if your environment dictates it
        Include parameters depending on the value of a user-specified parameter
        Provide tab completion and intellisense for parameters, depending on the environment

    Please keep in mind that all dynamic parameters you create, will not have corresponding variables created.
        Use New-DynamicParameter with 'CreateVariables' switch in your main code block,
        ('Process' for advanced functions) to create those variables.
        Alternatively, manually reference $PSBoundParameters for the dynamic parameter value.

    This function has two operating modes:

    1. All dynamic parameters created in one pass using pipeline input to the function. This mode allows to create dynamic parameters en masse,
    with one function call. There is no need to create and maintain custom RuntimeDefinedParameterDictionary.

    2. Dynamic parameters are created by separate function calls and added to the RuntimeDefinedParameterDictionary you created beforehand.
    Then you output this RuntimeDefinedParameterDictionary to the pipeline. This allows more fine-grained control of the dynamic parameters,
    with custom conditions and so on.

    .NOTES
    Credits to jrich523 and ramblingcookiemonster for their initial code and inspiration:
        https://github.com/RamblingCookieMonster/PowerShell/blob/master/New-DynamicParam.ps1
        http://ramblingcookiemonster.wordpress.com/2014/11/27/quick-hits-credentials-and-dynamic-parameters/
        http://jrich523.wordpress.com/2013/05/30/powershell-simple-way-to-add-dynamic-parameters-to-advanced-function/

    Credit to BM for alias and type parameters and their handling

    .PARAMETER Name
    Name of the dynamic parameter

    .PARAMETER Type
    Type for the dynamic parameter.  Default is string

    .PARAMETER Alias
    If specified, one or more aliases to assign to the dynamic parameter

    .PARAMETER Mandatory
    If specified, set the Mandatory attribute for this dynamic parameter

    .PARAMETER Position
    If specified, set the Position attribute for this dynamic parameter

    .PARAMETER HelpMessage
    If specified, set the HelpMessage for this dynamic parameter

    .PARAMETER DontShow
    If specified, set the DontShow for this dynamic parameter.
    This is the new PowerShell 4.0 attribute that hides parameter from tab-completion.
    http://www.powershellmagazine.com/2013/07/29/pstip-hiding-parameters-from-tab-completion/

    .PARAMETER ValueFromPipeline
    If specified, set the ValueFromPipeline attribute for this dynamic parameter

    .PARAMETER ValueFromPipelineByPropertyName
    If specified, set the ValueFromPipelineByPropertyName attribute for this dynamic parameter

    .PARAMETER ValueFromRemainingArguments
    If specified, set the ValueFromRemainingArguments attribute for this dynamic parameter

    .PARAMETER ParameterSetName
    If specified, set the ParameterSet attribute for this dynamic parameter. By default parameter is added to all parameters sets.

    .PARAMETER AllowNull
    If specified, set the AllowNull attribute of this dynamic parameter

    .PARAMETER AllowEmptyString
    If specified, set the AllowEmptyString attribute of this dynamic parameter

    .PARAMETER AllowEmptyCollection
    If specified, set the AllowEmptyCollection attribute of this dynamic parameter

    .PARAMETER ValidateNotNull
    If specified, set the ValidateNotNull attribute of this dynamic parameter

    .PARAMETER ValidateNotNullOrEmpty
    If specified, set the ValidateNotNullOrEmpty attribute of this dynamic parameter

    .PARAMETER ValidateRange
    If specified, set the ValidateRange attribute of this dynamic parameter

    .PARAMETER ValidateLength
    If specified, set the ValidateLength attribute of this dynamic parameter

    .PARAMETER ValidatePattern
    If specified, set the ValidatePattern attribute of this dynamic parameter

    .PARAMETER ValidateScript
    If specified, set the ValidateScript attribute of this dynamic parameter

    .PARAMETER ValidateSet
    If specified, set the ValidateSet attribute of this dynamic parameter

    .PARAMETER ParameterDefaultValue
    If specified, set a default value for the parameter.

    .PARAMETER Dictionary
    If specified, add resulting RuntimeDefinedParameter to an existing RuntimeDefinedParameterDictionary.
    Appropriate for custom dynamic parameters creation.

    If not specified, create and return a RuntimeDefinedParameterDictionary
    Aappropriate for a simple dynamic parameter creation.

    .EXAMPLE
    Create one dynamic parameter.

    This example illustrates the use of New-DynamicParameter to create a single dynamic parameter.
    The Drive's parameter ValidateSet is populated with all available volumes on the computer for handy tab completion / intellisense.

    Usage: Get-FreeSpace -Drive <tab>

    function Get-FreeSpace
    {
        [CmdletBinding()]
        Param()
        DynamicParam
        {
            # Get drive names for ValidateSet attribute
            $DriveList = ([System.IO.DriveInfo]::GetDrives()).Name

            # Create new dynamic parameter
            New-DynamicParameter -Name Drive -ValidateSet $DriveList -Type ([array]) -Position 0 -Mandatory
        }

        Process
        {
            # Dynamic parameters don't have corresponding variables created,
            # you need to call New-DynamicParameter with CreateVariables switch to fix that.
            New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

            $DriveInfo = [System.IO.DriveInfo]::GetDrives() | Where-Object {$Drive -contains $_.Name}
            $DriveInfo |
                ForEach-Object {
                    if(!$_.TotalFreeSpace)
                    {
                        $FreePct = 0
                    }
                    else
                    {
                        $FreePct = [System.Math]::Round(($_.TotalSize / $_.TotalFreeSpace), 2)
                    }
                    New-Object -TypeName psobject -Property @{
                        Drive = $_.Name
                        DriveType = $_.DriveType
                        'Free(%)' = $FreePct
                    }
                }
        }
    }

    .EXAMPLE
    Create several dynamic parameters not using custom RuntimeDefinedParameterDictionary (requires piping).

    In this example two dynamic parameters are created. Each parameter belongs to the different parameter set, so they are mutually exclusive.

    The Drive's parameter ValidateSet is populated with all available volumes on the computer.
    The DriveType's parameter ValidateSet is populated with all available drive types.

    Usage: Get-FreeSpace -Drive <tab>
        or
    Usage: Get-FreeSpace -DriveType <tab>

    Parameters are defined in the array of hashtables, which is then piped through the New-Object to create PSObject and pass it to the New-DynamicParameter function.
    Because of piping, New-DynamicParameter function is able to create all parameters at once, thus eliminating need for you to create and pass external RuntimeDefinedParameterDictionary to it.

    function Get-FreeSpace
    {
        [CmdletBinding()]
        Param()
        DynamicParam
        {
            # Array of hashtables that hold values for dynamic parameters
            $DynamicParameters = @(
                @{
                    Name = 'Drive'
                    Type = [array]
                    Position = 0
                    Mandatory = $true
                    ValidateSet = ([System.IO.DriveInfo]::GetDrives()).Name
                    ParameterSetName = 'Drive'
                },
                @{
                    Name = 'DriveType'
                    Type = [array]
                    Position = 0
                    Mandatory = $true
                    ValidateSet = [System.Enum]::GetNames('System.IO.DriveType')
                    ParameterSetName = 'DriveType'
                }
            )

            # Convert hashtables to PSObjects and pipe them to the New-DynamicParameter,
            # to create all dynamic paramters in one function call.
            $DynamicParameters | ForEach-Object {New-Object PSObject -Property $_} | New-DynamicParameter
        }
        Process
        {
            # Dynamic parameters don't have corresponding variables created,
            # you need to call New-DynamicParameter with CreateVariables switch to fix that.
            New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

            if($Drive)
            {
                $Filter = {$Drive -contains $_.Name}
            }
            elseif($DriveType)
            {
                $Filter =  {$DriveType -contains  $_.DriveType}
            }

            $DriveInfo = [System.IO.DriveInfo]::GetDrives() | Where-Object $Filter
            $DriveInfo |
                ForEach-Object {
                    if(!$_.TotalFreeSpace)
                    {
                        $FreePct = 0
                    }
                    else
                    {
                        $FreePct = [System.Math]::Round(($_.TotalSize / $_.TotalFreeSpace), 2)
                    }
                    New-Object -TypeName psobject -Property @{
                        Drive = $_.Name
                        DriveType = $_.DriveType
                        'Free(%)' = $FreePct
                    }
                }
        }
    }

    .EXAMPLE
    Create several dynamic parameters, with multiple Parameter Sets, not using custom RuntimeDefinedParameterDictionary (requires piping).

    In this example three dynamic parameters are created. Two of the parameters are belong to the different parameter set, so they are mutually exclusive.
    One of the parameters belongs to both parameter sets.

    The Drive's parameter ValidateSet is populated with all available volumes on the computer.
    The DriveType's parameter ValidateSet is populated with all available drive types.
    The DriveType's parameter ValidateSet is populated with all available drive types.
    The Precision's parameter controls number of digits after decimal separator for Free Space percentage.

    Usage: Get-FreeSpace -Drive <tab> -Precision 2
        or
    Usage: Get-FreeSpace -DriveType <tab> -Precision 2

    Parameters are defined in the array of hashtables, which is then piped through the New-Object to create PSObject and pass it to the New-DynamicParameter function.
    If parameter with the same name already exist in the RuntimeDefinedParameterDictionary, a new Parameter Set is added to it.
    Because of piping, New-DynamicParameter function is able to create all parameters at once, thus eliminating need for you to create and pass external RuntimeDefinedParameterDictionary to it.

    function Get-FreeSpace
    {
        [CmdletBinding()]
        Param()
        DynamicParam
        {
            # Array of hashtables that hold values for dynamic parameters
            $DynamicParameters = @(
                @{
                    Name = 'Drive'
                    Type = [array]
                    Position = 0
                    Mandatory = $true
                    ValidateSet = ([System.IO.DriveInfo]::GetDrives()).Name
                    ParameterSetName = 'Drive'
                },
                @{
                    Name = 'DriveType'
                    Type = [array]
                    Position = 0
                    Mandatory = $true
                    ValidateSet = [System.Enum]::GetNames('System.IO.DriveType')
                    ParameterSetName = 'DriveType'
                },
                @{
                    Name = 'Precision'
                    Type = [int]
                    # This will add a Drive parameter set to the parameter
                    Position = 1
                    ParameterSetName = 'Drive'
                },
                @{
                    Name = 'Precision'
                    # Because the parameter already exits in the RuntimeDefinedParameterDictionary,
                    # this will add a DriveType parameter set to the parameter.
                    Position = 1
                    ParameterSetName = 'DriveType'
                }
            )

            # Convert hashtables to PSObjects and pipe them to the New-DynamicParameter,
            # to create all dynamic paramters in one function call.
            $DynamicParameters | ForEach-Object {New-Object PSObject -Property $_} | New-DynamicParameter
        }
        Process
        {
            # Dynamic parameters don't have corresponding variables created,
            # you need to call New-DynamicParameter with CreateVariables switch to fix that.
            New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

            if($Drive)
            {
                $Filter = {$Drive -contains $_.Name}
            }
            elseif($DriveType)
            {
                $Filter = {$DriveType -contains  $_.DriveType}
            }

            if(!$Precision)
            {
                $Precision = 2
            }

            $DriveInfo = [System.IO.DriveInfo]::GetDrives() | Where-Object $Filter
            $DriveInfo |
                ForEach-Object {
                    if(!$_.TotalFreeSpace)
                    {
                        $FreePct = 0
                    }
                    else
                    {
                        $FreePct = [System.Math]::Round(($_.TotalSize / $_.TotalFreeSpace), $Precision)
                    }
                    New-Object -TypeName psobject -Property @{
                        Drive = $_.Name
                        DriveType = $_.DriveType
                        'Free(%)' = $FreePct
                    }
                }
        }
    }

    .Example
    Create dynamic parameters using custom dictionary.

    In case you need more control, use custom dictionary to precisely choose what dynamic parameters to create and when.
    The example below will create DriveType dynamic parameter only if today is not a Friday:

    function Get-FreeSpace
    {
        [CmdletBinding()]
        Param()
        DynamicParam
        {
            $Drive = @{
                Name = 'Drive'
                Type = [array]
                Position = 0
                Mandatory = $true
                ValidateSet = ([System.IO.DriveInfo]::GetDrives()).Name
                ParameterSetName = 'Drive'
            }

            $DriveType =  @{
                Name = 'DriveType'
                Type = [array]
                Position = 0
                Mandatory = $true
                ValidateSet = [System.Enum]::GetNames('System.IO.DriveType')
                ParameterSetName = 'DriveType'
            }

            # Create dictionary
            $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Add new dynamic parameter to dictionary
            New-DynamicParameter @Drive -Dictionary $DynamicParameters

            # Add another dynamic parameter to dictionary, only if today is not a Friday
            if((Get-Date).DayOfWeek -ne [DayOfWeek]::Friday)
            {
                New-DynamicParameter @DriveType -Dictionary $DynamicParameters
            }

            # Return dictionary with dynamic parameters
            $DynamicParameters
        }
        Process
        {
            # Dynamic parameters don't have corresponding variables created,
            # you need to call New-DynamicParameter with CreateVariables switch to fix that.
            New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

            if($Drive)
            {
                $Filter = {$Drive -contains $_.Name}
            }
            elseif($DriveType)
            {
                $Filter =  {$DriveType -contains  $_.DriveType}
            }

            $DriveInfo = [System.IO.DriveInfo]::GetDrives() | Where-Object $Filter
            $DriveInfo |
                ForEach-Object {
                    if(!$_.TotalFreeSpace)
                    {
                        $FreePct = 0
                    }
                    else
                    {
                        $FreePct = [System.Math]::Round(($_.TotalSize / $_.TotalFreeSpace), 2)
                    }
                    New-Object -TypeName psobject -Property @{
                        Drive = $_.Name
                        DriveType = $_.DriveType
                        'Free(%)' = $FreePct
                    }
                }
        }
    }
    #>
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'DynamicParameter')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [System.Type]$Type = [int],

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [string[]]$Alias,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$Mandatory,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [int]$Position,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [string]$HelpMessage,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$DontShow,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValueFromPipeline,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValueFromPipelineByPropertyName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValueFromRemainingArguments,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [string]$ParameterSetName = '__AllParameterSets',

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$AllowNull,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$AllowEmptyString,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$AllowEmptyCollection,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValidateNotNull,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValidateNotNullOrEmpty,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateCount(2, 2)]
        [int[]]$ValidateCount,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateCount(2, 2)]
        [int[]]$ValidateRange,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateCount(2, 2)]
        [int[]]$ValidateLength,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [string]$ValidatePattern,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$ValidateScript,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ValidateSet,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        $ParameterDefaultValue,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if (!($_ -is [System.Management.Automation.RuntimeDefinedParameterDictionary])) {
                    Throw 'Dictionary must be a System.Management.Automation.RuntimeDefinedParameterDictionary object'
                }
                $true
            })]
        $Dictionary = $false,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'CreateVariables')]
        [switch]$CreateVariables,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'CreateVariables')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                # System.Management.Automation.PSBoundParametersDictionary is an internal sealed class,
                # so one can't use PowerShell's '-is' operator to validate type.
                if ($_.GetType().Name -ne 'PSBoundParametersDictionary') {
                    Throw 'BoundParameters must be a System.Management.Automation.PSBoundParametersDictionary object'
                }
                $true
            })]
        $BoundParameters
    )

    Begin {
        Write-Verbose 'Creating new dynamic parameters dictionary'
        $InternalDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary

        Write-Verbose 'Getting common parameters'
        function _temp { [CmdletBinding()] Param() }
        $CommonParameters = (Get-Command _temp).Parameters.Keys
    }

    Process {
        if ($CreateVariables) {
            Write-Verbose 'Creating variables from bound parameters'
            Write-Debug 'Picking out bound parameters that are not in common parameters set'
            $BoundKeys = $BoundParameters.Keys | Where-Object { $CommonParameters -notcontains $_ }

            foreach ($Parameter in $BoundKeys) {
                Write-Debug "Setting existing variable for dynamic parameter '$Parameter' with value '$($BoundParameters.$Parameter)'"
                Set-Variable -Name $Parameter -Value $BoundParameters.$Parameter -Scope 1 -Force
            }
        }
        else {
            Write-Verbose 'Looking for cached bound parameters'
            Write-Debug 'More info: https://beatcracker.wordpress.com/2014/12/18/psboundparameters-pipeline-and-the-valuefrompipelinebypropertyname-parameter-attribute'
            $StaleKeys = @()
            $StaleKeys = $PSBoundParameters.GetEnumerator() |
                ForEach-Object {
                if ($_.Value.PSobject.Methods.Name -match '^Equals$') {
                    # If object has Equals, compare bound key and variable using it
                    if (!$_.Value.Equals((Get-Variable -Name $_.Key -ValueOnly -Scope 0))) {
                        $_.Key
                    }
                }
                else {
                    # If object doesn't has Equals (e.g. $null), fallback to the PowerShell's -ne operator
                    if ($_.Value -ne (Get-Variable -Name $_.Key -ValueOnly -Scope 0)) {
                        $_.Key
                    }
                }
            }
            if ($StaleKeys) {
                [string[]]"Found $($StaleKeys.Count) cached bound parameters:" + $StaleKeys | Write-Debug
                Write-Verbose 'Removing cached bound parameters'
                $StaleKeys | ForEach-Object {[void]$PSBoundParameters.Remove($_)}
            }

            # Since we rely solely on $PSBoundParameters, we don't have access to default values for unbound parameters
            Write-Verbose 'Looking for unbound parameters with default values'

            Write-Debug 'Getting unbound parameters list'
            $UnboundParameters = (Get-Command -Name ($PSCmdlet.MyInvocation.InvocationName)).Parameters.GetEnumerator()  |
                # Find parameters that are belong to the current parameter set
            Where-Object { $_.Value.ParameterSets.Keys -contains $PsCmdlet.ParameterSetName } |
                Select-Object -ExpandProperty Key |
                # Find unbound parameters in the current parameter set
												Where-Object { $PSBoundParameters.Keys -notcontains $_ }

            # Even if parameter is not bound, corresponding variable is created with parameter's default value (if specified)
            Write-Debug 'Trying to get variables with default parameter value and create a new bound parameter''s'
            $tmp = $null
            foreach ($Parameter in $UnboundParameters) {
                $DefaultValue = Get-Variable -Name $Parameter -ValueOnly -Scope 0
                if (!$PSBoundParameters.TryGetValue($Parameter, [ref]$tmp) -and $DefaultValue) {
                    $PSBoundParameters.$Parameter = $DefaultValue
                    Write-Debug "Added new parameter '$Parameter' with value '$DefaultValue'"
                }
            }

            if ($Dictionary) {
                Write-Verbose 'Using external dynamic parameter dictionary'
                $DPDictionary = $Dictionary
            }
            else {
                Write-Verbose 'Using internal dynamic parameter dictionary'
                $DPDictionary = $InternalDictionary
            }

            Write-Verbose "Creating new dynamic parameter: $Name"

            # Shortcut for getting local variables
            $GetVar = {Get-Variable -Name $_ -ValueOnly -Scope 0}

            # Strings to match attributes and validation arguments
            $AttributeRegex = '^(Mandatory|Position|ParameterSetName|DontShow|HelpMessage|ValueFromPipeline|ValueFromPipelineByPropertyName|ValueFromRemainingArguments)$'
            $ValidationRegex = '^(AllowNull|AllowEmptyString|AllowEmptyCollection|ValidateCount|ValidateLength|ValidatePattern|ValidateRange|ValidateScript|ValidateSet|ValidateNotNull|ValidateNotNullOrEmpty)$'
            $AliasRegex = '^Alias$'

            Write-Debug 'Creating new parameter''s attirubutes object'
            $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute

            Write-Debug 'Looping through the bound parameters, setting attirubutes...'
            switch -regex ($PSBoundParameters.Keys) {
                $AttributeRegex {
                    Try {
                        $ParameterAttribute.$_ = . $GetVar
                        Write-Debug "Added new parameter attribute: $_"
                    }
                    Catch {
                        $_
                    }
                    continue
                }
            }

            if ($DPDictionary.Keys -contains $Name) {
                Write-Verbose "Dynamic parameter '$Name' already exist, adding another parameter set to it"
                $DPDictionary.$Name.Attributes.Add($ParameterAttribute)
            }
            else {
                Write-Verbose "Dynamic parameter '$Name' doesn't exist, creating"

                Write-Debug 'Creating new attribute collection object'
                $AttributeCollection = New-Object -TypeName Collections.ObjectModel.Collection[System.Attribute]

                Write-Debug 'Looping through bound parameters, adding attributes'
                switch -regex ($PSBoundParameters.Keys) {
                    $ValidationRegex {
                        Try {
                            $ParameterOptions = New-Object -TypeName "System.Management.Automation.${_}Attribute" -ArgumentList (. $GetVar) -ErrorAction Stop
                            $AttributeCollection.Add($ParameterOptions)
                            Write-Debug "Added attribute: $_"
                        }
                        Catch {
                            $_
                        }
                        continue
                    }

                    $AliasRegex {
                        Try {
                            $ParameterAlias = New-Object -TypeName System.Management.Automation.AliasAttribute -ArgumentList (. $GetVar) -ErrorAction Stop
                            $AttributeCollection.Add($ParameterAlias)
                            Write-Debug "Added alias: $_"
                            continue
                        }
                        Catch {
                            $_
                        }
                    }
                }

                Write-Debug 'Adding attributes to the attribute collection'
                $AttributeCollection.Add($ParameterAttribute)

                Write-Debug 'Finishing creation of the new dynamic parameter'
                $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList @($Name, $Type, $AttributeCollection)

                if ($null -ne $ParameterDefaultValue) {
                    $Parameter.Value = $ParameterDefaultValue
                }

                Write-Debug 'Adding dynamic parameter to the dynamic parameter dictionary'
                $DPDictionary.Add($Name, $Parameter)
            }
        }
    }

    End {
        if (!$CreateVariables -and !$Dictionary) {
            Write-Verbose 'Writing dynamic parameter dictionary to the pipeline'
            $DPDictionary
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Add-OMPAutoLoadModule.md
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
        $Script:OMPProfile['AutoLoadModules'] = @($Script:OMPProfile['AutoLoadModules'] + $Name | Sort-Object -Unique)
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Add-OMPPersonalFunction.md
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Add-OMPPlugin.md
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
            $PluginPlatform = (Get-OMPPlugin $Name).Platform
            if ($PluginPlatform -contains (Get-OMPState).Platform) {
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
                Write-Warning "This plugin is not supported on $((Get-OMPState).Platform) and has NOT been loaded!"
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Add-OMPProfileSetting.md
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Export-OMPProfile.md
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



function Get-OMPGitBranchName {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPGitBranchName.md
    #>
    $currentBranch = ''
    try {
        git branch | foreach {
            if ($_ -match "^\* (.*)") {
                $currentBranch += $matches[1]
            }
        }
    }
    catch {
        # do nothing but git likely isn't available
    }

    return $currentBranch
}



function Get-OMPGitStatus {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPGitStatus.md
    #>
    $deleted = 0
    $modified = 0
    $added = 0
    $untracked = 0

    try {
        $gitstatus = git status --porcelain --short
        $deleted = ($gitstatus | select-string '^D\s').count
        $modified = ($gitstatus | select-string '^M\s').count
        $added = ($gitstatus | select-string '^A\s').count
        $untracked = ($gitstatus | select-string '^\?\?\s').count
    }
    catch {}

    return @{
        "untracked" = $untracked
        "added" = $added
        "modified" = $modified
        "deleted" = $deleted
    }
}



function Get-OMPHostState {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPHostState.md
    #>

    [CmdletBinding()]
    param(
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    process {
    }
    end {
        $Script:HostState
        Write-Verbose "$($FunctionName): End."
    }
}



function Get-OMPIPAddress {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPIPAddress.md
    #>
    [CmdletBinding()]
    param(
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    process {
    }
    end {
        # Retreive IP address informaton from dot net core only functions (should run on both linux and windows properly)
        $NetworkInterfaces = @([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | Where-Object {($_.OperationalStatus -eq 'Up')})
        $NetworkInterfaces | Foreach-Object {
            $_.GetIPProperties() | Where-Object {$_.GatewayAddresses} | Foreach-Object {
                $Gateway = $_.GatewayAddresses.Address.IPAddressToString
                $DNSAddresses = @($_.DnsAddresses | Foreach-Object {$_.IPAddressToString})
                $_.UnicastAddresses | Where-Object {$_.Address -notlike '*::*'} | Foreach-Object {
                    New-Object PSObject -Property @{
                        IP = $_.Address
                        Prefix = $_.PrefixLength
                        Gateway = $Gateway
                        DNS = $DNSAddresses
                    }
                }
            }
        }
        Write-Verbose "$($FunctionName): End."
    }
}



function Get-OMPLoadedFunction {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPLoadedFunction.md
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Name = '*'
    )
    Process {
        Get-ChildItem -Path "Function:\$Name" -Recurse | Where-Object { $null -ne $_.ohmypsh } | Select Name,ohmypsh
    }
}


function GET-OMPOSPlatform {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPOSPlatform.md
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [Switch]$IncludeLinuxDetails
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    process {}
    end {
        $ThisIsCoreCLR = if ($IsCoreCLR) {$True} else {$False}
        $ThisIsLinux = if ($IsLinux) {$True} else {$False} #$Runtime::IsOSPlatform($OSPlatform::Linux)
        $ThisIsOSX = if ($IsOSX) {$True} else {$False} #$Runtime::IsOSPlatform($OSPlatform::OSX)
        $ThisIsWindows = if ($IsWindows) {$True} else {$False} #$Runtime::IsOSPlatform($OSPlatform::Windows)

        if (-not ($ThisIsLinux -or $ThisIsOSX)) {
            $ThisIsWindows = $true
        }

        if ($ThisIsLinux) {
            if ($IncludeLinuxDetails) {
                $LinuxInfo = Get-Content /etc/os-release | ConvertFrom-StringData
                $IsUbuntu = $LinuxInfo.ID -match 'ubuntu'
                if ($IsUbuntu -and $LinuxInfo.VERSION_ID -match '14.04') {
                    return 'Ubuntu 14.04'
                }
                if ($IsUbuntu -and $LinuxInfo.VERSION_ID -match '16.04') {
                    return 'Ubuntu 16.04'
                }
                if ($LinuxInfo.ID -match 'centos' -and $LinuxInfo.VERSION_ID -match '7') {
                    return 'CentOS'
                }
            }
            return 'Linux'
        }
        elseif ($ThisIsOSX) {
            return 'OSX'
        }
        elseif ($ThisIsWindows) {
            return 'Windows'
        }
        else {
            return 'Unknown'
        }
        Write-Verbose "$($FunctionName): End."
    }
}



function Get-OMPPlugin {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPPlugin.md
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


function Get-OMPPowerShellProfile {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPPowerShellProfile.md
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('AllUsersAllHosts','AllUsersCurrentHost','CurrentUserAllHosts','CurrentUserCurrentHost')]
        [string]$ProfileType = 'CurrentUserCurrentHost'
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    end {
        if (Test-Path $PROFILE.$ProfileType) {
            Get-Content $PROFILE.$ProfileType
        }
        else {
            Write-Warning "$($FunctionName): Profile does not exist - $($PROFILE.$ProfileType)"
        }
        Write-Verbose "$($FunctionName): End."
    }
}



function Get-OMPPowerShellProfileState {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPPowerShellProfileState.md
    #>

    [CmdletBinding()]
    param(
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."

        $ProfileTypes = @('AllUsersAllHosts','AllUsersCurrentHost','CurrentUserAllHosts','CurrentUserCurrentHost')
    }
    end {
        $order = 0
        Foreach ($PType in $Profiletypes) {
            $order++
            New-Object -TypeName psobject -Property @{
                Name = $PType
                Exists = if (test-path $PROFILE.$Ptype) {$true} else {$false}
                Path = $PROFILE.$Ptype
                Order = $order
            } | Select Order, Name, Exists, Path
        }
        Write-Verbose "$($FunctionName): End."
    }
}



Function Get-OMPProfilePath {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPProfilePath.md
    #>
    [CmdletBinding()]
	param ()

    $Script:OMPProfileExportFile
}


Function Get-OMPProfileSetting {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPProfileSetting.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateScript({
            (($Script:OMPProfile).Keys -contains $_ ) -or ([string]::IsNullOrEmpty($_))
        })]
        [String]$Name
    )
    process {
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPPromptColor.md
    #>
    [CmdletBinding()]
	param ()

    [psobject]@{
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


function Get-OMPState {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPState.md
    #>

    [CmdletBinding()]
    param(
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    process {}
    end {
        $Script:OMPState
        Write-Verbose "$($FunctionName): End."
    }
}



function Get-OMPSystemUpTime {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPSystemUpTime.md
    #>

    [CmdletBinding()]
    param(
        [switch]$FromSleep
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
        function Test-EventLogSource {
            param(
                [Parameter(Mandatory = $true)]
                [string] $SourceName
            )
            try {
                [System.Diagnostics.EventLog]::SourceExists($SourceName)
            }
            catch {
                $false
            }
        }
    }
    process {}
    end {
        switch ( Get-OMPOSPlatform -ErrorVariable null ) {
            'Linux' {
                # Add me!
            }
            'OSX' {
                # Add me!
            }
            Default {
                if (-not $FromSleep) {
                    $os = Get-WmiObject win32_operatingsystem
                    $Uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
                }
                elseif (Test-EventLogSource 'Microsoft-Windows-Power-Troubleshooter') {
                    try {
                        $LastPowerEvent = (Get-EventLog -LogName system -Source 'Microsoft-Windows-Power-Troubleshooter' -Newest 1 -ErrorAction:Stop).TimeGenerated
                    }
                    catch {
                        $error.Clear()
                    }
                    if ($LastPowerEvent -ne $null) {
                        $Uptime = ( (Get-Date) - $LastPowerEvent )
                    }
                }
                if ($Uptime -ne $null) {
                    $Display = "" + $Uptime.Days + " days / " + $Uptime.Hours + " hours / " + $Uptime.Minutes + " minutes"
                    Write-Output $Display
                }
            }
        }
        Write-Verbose "$($FunctionName): End."
    }
}



function Get-OMPTheme {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Get-OMPTheme.md
    #>

    [CmdletBinding()]
    [OutputType('OMP.ThemeStatus')]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateScript({
            (@((Get-ChildItem (Join-Path $Script:ModulePath 'Themes') -File -Filter '*.ps1').Name | ForEach-Object {$_ -replace '.ps1',''}) -contains $_) -or ([string]::IsNullOrEmpty($_))
        })]
        [String]$Name
    )
    Begin {
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
    Process {
        if ([string]::IsNullOrEmpty($Name)) {
            $Themes = @((Get-ChildItem (Join-Path $Script:ModulePath 'Themes') -File -Filter '*.ps1').Name | ForEach-Object {$_ -replace '.ps1',''})
        }
        else {
            $Themes = @((Get-ChildItem (Join-Path $Script:ModulePath "Themes\$Name.ps1") -File -Filter '*.ps1').Name | ForEach-Object {$_ -replace '.ps1',''})
        }
        $Themes | ForEach-Object {
            $ThemePath = Join-Path $Script:ModulePath "Themes\$($_).ps1"
            $object = New-Object -TypeName PSObject -Property @{
                'Name' = $_
                'Loaded' = if ($Script:OMPProfile['Theme'] -eq $_) {$true} else {$false}
                'Path' = $ThemePath
                'Content' = Get-Content $ThemePath
            }

            $object.PSTypeNames.Insert(0,'OMP.ThemeStatus')
            $object | Add-Member MemberSet PSStandardMembers $PSStandardMembers

            $object
        }
    }
    End {
        Write-Verbose "$($FunctionName): End."
    }
}


Function Import-OMPModule {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Import-OMPModule.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Name,
        [Parameter()]
        [string]$Prefix
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."

        $AllModules = @()
        $ImportSplat = $Script:OMPProfile['OMPModuleInstallSplat']
        if (-not [string]::IsNullOrEmpty($Prefix)) {
            $ImportSplat.Prefix = $Prefix
        }
        if ($Force) {
            $ImportSplat.Force = $true
        }
    }
    Process {
        $AllModules += $Name
    }
    End {
        Foreach ($Module in $AllModules) {
            if ( $null -eq (Get-Module $Module -ListAvailable) ) {
                if ($Script:OMPProfile['AutoInstallModules']) {
                    Write-Verbose "$($FunctionName): Attempting to install missing module: $($Module)"
                    try {
                        Import-Module PowerShellGet -Force
                        $null = Install-Module $Module -Scope:CurrentUser
                        Write-Verbose "$($FunctionName): Module Installed - $($Module)"
                    }
                    catch {
                        throw "Unable to find or install the following module requirement: $($Module)"
                    }
                }
                else {
                    throw "$($Module) was not found and automatic installation of modules is disabled in this profile!"
                }
            }

            # If we made it this far and the module isn't loaded, try to do so now. We have to import globaly for it to show up in the calling user's session.
            if (-not (get-module $Module)) {
                Write-Verbose "$($FunctionName): Attempting to import module - $Module"
                Import-Module $Module -Global -force @ImportSplat
            }
            else {
                Write-Verbose "$($FunctionName): $Module is already loaded"
                return
            }

            # check if it loaded properly
            if (-not (get-module $Module)) {
                throw "$($Module) was not able to load!"
            }
            else {
                Write-Verbose "$($FunctionName): Module Imported - $Module"
            }
        }
    }
}


Function Import-OMPProfile {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Import-OMPProfile.md
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
    $MissingSettings = @($Script:OMPProfile.Keys | Where-Object {$ProfileSettings -notcontains $_})
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Invoke-OMPPluginShutdown.md
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/New-OMPPlugin.md
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


Function New-OMPPluginManifest {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/New-OMPPluginManifest.md
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



Function Optimize-OMPProfile {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Optimize-OMPProfile.md
    #>
    [CmdletBinding()]
    Param()
    if ((Test-OMPIsElevated) -and ((Get-OMPOSPlatform) -eq 'Windows')) {
        Write-Output 'Optimizing assemblies for PowerShell profile.'
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
    else {
        Write-Warning "Not able to optimize assemblies either because this prompt is not eleveted or the platform is not Windows."
    }
}


Function Remove-OMPAutoLoadModule {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Remove-OMPAutoLoadModule.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name,
        [Parameter(Position = 1)]
        [switch]$NoProfileUpdate
    )
    try {
        Remove-OMPModule -Name $Name -ErrorAction:SilentlyContinue
        $Script:OMPProfile['AutoLoadModules'] = @($Script:OMPProfile['AutoLoadModules'] | Where-Object {$_ -ne $Name} | Sort-Object -Unique)
        if (-not $NoProfileUpdate) {
            Export-OMPProfile
        }
    }
    catch {
        # Do nothing
    }
}


Function Remove-OMPModule {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Remove-OMPModule.md
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Remove-OMPPersonalFunction.md
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Remove-OMPPlugin.md
    #>
    [CmdletBinding()]
	param (
        [Parameter()]
        [switch]$Force,
        [Parameter()]
        [switch]$NoProfileUpdate
    )
    dynamicparam {
        # Create dictionary
        $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $NewParamSettings = @{
            Name = 'Name'
            Position = 0
            Type = 'string'
            HelpMessage = 'The plugin to remove.'
            ValueFromPipeline = $true
            ValueFromPipelineByPropertyName = $true
        }
        $NewParamSettings.ValidateSet = @($Script:OMPState['PluginsLoaded'])
        if ((@($Script:OMPState['PluginsLoaded']).Count -gt 0) -and (-not $force)) {
            $NewParamSettings.ValidateSet = (Get-OMPProfileSetting).Plugins
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
    process {
        # Pull in the dynamic parameters first
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

        $LoadedPlugins = $Script:OMPState['PluginsLoaded']

        if (-not [string]::IsNullOrEmpty($Name)) {
            if ((@($Script:OMPState['PluginsLoaded']) -contains $Name) -or $Force) {
                $Unload = $null
                $PluginPath = (Get-OMPPlugin | Where {$_.Name -eq $Name}).Path
                $UnloadScript = Join-Path $PluginPath 'Load.ps1'

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
}


Function Remove-OMPProfileSetting {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Remove-OMPProfileSetting.md
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


function Reset-OMPConsoleOverride {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Reset-OMPConsoleOverride.md
    #>

    [CmdletBinding()]
    param(
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."

        function linksto($path, $target) {
            if(!(isshortcut $path)) { return $false }

            $path = "$(resolve-path $path)"

            $shell = new-object -com wscript.shell -strict
            $shortcut = $shell.createshortcut($path)

            $result = $shortcut.targetpath -eq $target
            [Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) > $null
            return $result
        }

        function isshortcut($path) {
            if(!(test-path $path)) { return $false }
            if($path -notmatch '\.lnk$') { return $false }
            return $true
        }

        # based on code from coapp:
        # https://github.com/coapp/coapp/tree/master/toolkit/Shell
        $cs = @"
        using System;
        using System.Runtime.InteropServices;
        using System.Runtime.InteropServices.ComTypes;
        namespace concfg {
            public static class Shortcut {
                public static void RmProps(string path) {
                    var NT_CONSOLE_PROPS_SIG = 0xA0000002;
                    var STGM_READ = 0;
                    var lnk = new ShellLinkCoClass();
                    var data = (IShellLinkDataList)lnk;
                    var file = (IPersistFile)lnk;
                    file.Load(path, STGM_READ);
                    data.RemoveDataBlock(NT_CONSOLE_PROPS_SIG);
                    file.Save(path, true);
                    Marshal.ReleaseComObject(data);
                    Marshal.ReleaseComObject(file);
                    Marshal.ReleaseComObject(lnk);
                }
            }
            [ComImport, Guid("00021401-0000-0000-C000-000000000046")]
            class ShellLinkCoClass { }
            [ComImport,
            InterfaceType(ComInterfaceType.InterfaceIsIUnknown),
            Guid("45e2b4ae-b1c3-11d0-b92f-00a0c90312e1")]
            interface IShellLinkDataList {
                void _VtblGap1_2(); // AddDataBlock, CopyDataBlock
                [PreserveSig]
                Int32 RemoveDataBlock(UInt32 dwSig);
                void _VtblGap2_2(); // GetFlag, SetFlag
            }
        }
"@

        add-type -typedef $cs -lang csharp

        function rmprops($path) {
            if(!(isshortcut $path)) { return $false }

            $path = "$(resolve-path $path)"
            try { [concfg.shortcut]::rmprops($path) }
            catch [UnauthorizedAccessException] {
                return $false
            }
            $true
        }

        $pspath = "$pshome\powershell.exe"
        $pscorepath = "$pshome\pwsh.exe"

        function cleandir($dir) {
            if(!(test-path $dir)) { return }

            gci $dir | % {
                if($_.psiscontainer) { cleandir $_.fullname }
                else {
                    $path = $_.fullname
                    if((linksto $path $pspath) -or (linksto $path $pscorepath)) {
                        if(!(rmprops $path)) {
                            write-host "warning: admin permission is required to remove console props from $path" -f darkyellow
                        }
                    }
                }
            }
        }
    }
    process {
    }
    end {
        if(test-path hkcu:console) {
            gci hkcu:console | % {
                write-host "removing $($_.name)"
                rm "registry::$($_.name)"
            }
        }
        $dirs = @(
            "~\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar",
            "~\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell",
            "\ProgramData\Microsoft\Windows\Start Menu\Programs"
        )

        $dirs | % {	cleandir $_ }
        Write-Verbose "$($FunctionName): End."
    }
}



Function Restore-OMPConsoleColor {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Restore-OMPConsoleColor.md
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original console colors (this does not include psreadline configurations)'
    $OriginalColors = $Script:HostState['colors']

    Set-OMPConsoleColor @OriginalColors
}


Function Restore-OMPConsolePrompt {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Restore-OMPConsolePrompt.md
    #>
    [CmdletBinding()]
	param ()
    #if ($null -ne $Script:OldPrompt) {
        Write-Verbose 'Restoring original Prompt function'
        Set-Item Function:\prompt $Script:HostState['Prompt']
    #}
}


Function Restore-OMPConsoleTitle {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Restore-OMPConsoleTitle.md
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original console title'
    $Global:Host.UI.RawUI.WindowTitle = $Script:HostState['Title']
}


Function Restore-OMPOriginalAlias {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Restore-OMPOriginalAlias.md
    #>
    [CmdletBinding()]
	param ()
    # I cannot figure out a way to import these automatically back into the users session when the module unloads
    # so for now tell the user how to do so themselves if so desired.
    $Path = $Script:HostState['Aliases']
    if ((Test-Path $Path)) {
        Write-Output ''
        Write-Output "Original aliases stored in $Path"
        Write-Output 'To restore these into your session run the following: '
        Write-Output ''
        Write-Output ". $Path"
        Write-Output ''
    }
}


Function Restore-OMPOriginalPSDefaultParameter {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Restore-OMPOriginalPSDefaultParameter.md
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original PSDefaultParameters variable'
    $Global:PSDefaultParameterValues = $Script:HostState['PSDefaultParameterValues'].Clone()
}


Function Restore-OMPOriginalTabCompletion {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Restore-OMPOriginalTabCompletion.md
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original TabExpansion function'
    Set-Item function:\TabExpansion $Script:HostState['TabExpansion']

    Write-Verbose 'Restoring original TabExpansion2 function'
    Set-Item function:\TabExpansion2 $Script:HostState['TabExpansion2']
}


Function Restore-OMPPSReadline {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Restore-OMPPSReadline.md
    #>
    [CmdletBinding()]
	param ()
    Write-Verbose 'Restoring original psreadline settings and colors'
    if ($null -ne $Script:PSReadlineState) {
        $TokenKinds = @(
            'Comment',
            'Keyword',
            'String',
            'Operator',
            'Variable',
            'Command',
            'Parameter',
            'Type',
            'Number',
            'Member')
        $PSReadlineSplat = @{}
        Foreach ($ReadlineOption in ($Script:PSReadlineState | Get-Member -MemberType:Property).Name) {
            if ($ReadlineOption -match '^(.*)(ForegroundColor|BackgroundColor)$') {
                $Token = $Matches[1]
                $ParamName = $Matches[2]
                if ($TokenKinds -contains $Token) {
                    Write-Output "Restoring $ParamName for $Token to $(($Script:PSReadlineState).$ReadlineOption)"
                    $Psreadlinesplat = @{
                        TokenKind = $Token
                        $ParamName = ($Script:PSReadlineState).$ReadlineOption
                    }

                    Set-PSReadlineOption @Psreadlinesplat
                }
            }
            else {
                $PSReadlineSplat.$ReadlineOption = ($Script:PSReadlineState).$ReadlineOption
            }
        }

        Set-PSReadlineOption @PSReadlineSplat
    }

    Set-OMPConsoleColor @OriginalColors
}


function Set-OMPConsoleColor {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Set-OMPConsoleColor.md
    #>

    [CmdletBinding()]
    param(
        $BackgroundColor,
        $ForegroundColor,
        $ErrorForegroundColor,
        $WarningForegroundColor,
        $DebugForegroundColor,
        $VerboseForegroundColor,
        $ProgressForegroundColor,
        $ErrorBackgroundColor,
        $WarningBackgroundColor,
        $DebugBackgroundColor,
        $VerboseBackgroundColor,
        $ProgressBackgroundColor
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
        $PsreadlineIsLoaded = if (get-module psreadline) {$true} else {$false}
    }
    process {
        if ($PsreadlineIsLoaded) {
            Write-Verbose "$($FunctionName): Psreadline is loaded, setting psreadline options."
            $PSReadlineOptions = Get-PSReadlineOption
        }
        else {
            Write-Verbose "$($FunctionName): Psreadline is not loaded, setting default host console colors."
        }
        if ($null -ne $BackgroundColor) {
            Write-Verbose "$($FunctionName): Setting the BackgroundColor"
            if ($PsreadlineIsLoaded) {
                $PSReadlineOptions.CommandBackgroundColor = $BackgroundColor
            }
            $Host.UI.RawUI.BackgroundColor = [System.ConsoleColor]$BackgroundColor
        }
        if ($null -ne $ForegroundColor) {
            Write-Verbose "$($FunctionName): Setting the ForegroundColor"
            if ($PsreadlineIsLoaded) {
                $PSReadlineOptions.CommandForegroundColor = $ForegroundColor
            }
            $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]$ForegroundColor
        }
        if (($host.PrivateData | get-member -Type:Property).Count -gt 0) {
            if ($null -ne $ErrorForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the ErrorForegroundColor"
                if ($PsreadlineIsLoaded) {
                    $PSReadlineOptions.ErrorForegroundColor = $ErrorForegroundColor
                }
                $Host.PrivateData.ErrorForegroundColor = [System.ConsoleColor]$ErrorForegroundColor
            }
            if ($null -ne $WarningForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the WarningforegroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.WarningForegroundColor = $WarningForegroundColor
                #}
                $Host.PrivateData.WarningForegroundColor = [System.ConsoleColor]$WarningForegroundColor
            }
            if ($null -ne $DebugForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the DebugForegroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.DebugForegroundColor = $DebugForegroundColor
                #}
                $Host.PrivateData.DebugForegroundColor = [System.ConsoleColor]$DebugForegroundColor
            }
            if ($null -ne $VerboseForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the VerboseForegroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.VerboseForegroundColor = $VerboseForegroundColor
                #}
                $Host.PrivateData.VerboseForegroundColor = [System.ConsoleColor]$VerboseForegroundColor
            }
            if ($null -ne $ProgressForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the ProgressForegroundColor"
               # if ($PsreadlineIsLoaded) {
               #     $PSReadlineOptions.ProgressForegroundColor = $ProgressForegroundColor
               # }
                $Host.PrivateData.ProgressForegroundColor = [System.ConsoleColor]$ProgressForegroundColor
            }
            if ($null -ne $ErrorBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the ErrorBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.ErrorBackgroundColor = $ErrorBackgroundColor
                #}
                $Host.PrivateData.ErrorBackgroundColor = [System.ConsoleColor]$ErrorBackgroundColor
            }
            if ($null -ne $WarningBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the WarningBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.WarningBackgroundColor = $WarningBackgroundColor
                #}
                $Host.PrivateData.WarningBackgroundColor = [System.ConsoleColor]$WarningBackgroundColor
            }
            if ($null -ne $DebugBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the DebugBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.DebugBackgroundColor = $DebugBackgroundColor
                #}
                $Host.PrivateData.DebugBackgroundColor = [System.ConsoleColor]$DebugBackgroundColor
            }
            if ($null -ne $VerboseBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the VerboseBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.VerboseBackgroundColor = $VerboseBackgroundColor
                #}
                $Host.PrivateData.VerboseBackgroundColor = [System.ConsoleColor]$VerboseBackgroundColor
            }
            if ($null -ne $ProgressBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the ProgressBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.ProgressBackgroundColor = $ProgressBackgroundColor
                #}
                $Host.PrivateData.ProgressBackgroundColor = [System.ConsoleColor]$ProgressBackgroundColor
            }
        }
    }
    end {
        Write-Verbose "$($FunctionName): End."
    }
}



function Set-OMPGitOutput {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Set-OMPGitOutput.md
    #>

    [CmdletBinding()]
	param (
        [Parameter(Position = 0)]
        [ValidateSet('psgit','posh-git','script')]
        [string]$Name = 'script'
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    end {
        switch ($Name) {
            'psgit' {
                Write-Verbose "$($FunctionName): Setting to psgit, attempting to unload posh-git if loaded."
                Remove-OMPAutoLoadModule 'posh-git' -ErrorAction:SilentlyContinue
                if (get-module 'posh-git') { Remove-Module 'posh-git' -ErrorAction:SilentlyContinue }

                try {
                    Import-OMPModule 'psgit'
                    Add-OMPAutoLoadModule 'psgit'
                    Set-OMPProfileSetting -Name:OMPGitOutput -Value:$Name
                }
                catch {
                    Write-Warning "$($FunctionName): Unable to load psgit module! Leaving current OMP git output setting in place."
                }
            }
            'posh-git' {
                Write-Verbose "$($FunctionName): Setting to posh-git, attempting to unload psgit if loaded."
                Remove-OMPAutoLoadModule 'psgit' -ErrorAction:SilentlyContinue
                if (get-module 'psgit') { Remove-Module 'psgit' -ErrorAction:SilentlyContinue }

                try {
                    Import-OMPModule 'posh-git'
                    Add-OMPAutoLoadModule 'posh-git'
                    Set-OMPProfileSetting -Name:OMPGitOutput -Value:$Name
                }
                catch {
                    Write-Warning "$(FunctionName): Unable to load posh-git module! Leaving current OMP git output setting in place."
                }
            }
            Default {
                Write-Verbose "$($FunctionName): Setting to script, leaving git modules as they are"
                Remove-OMPAutoLoadModule 'psgit'
                Remove-OMPAutoLoadModule 'posh-git'
                if (get-module 'psgit') { Remove-Module 'psgit' -ErrorAction:SilentlyContinue }
                if (get-module 'posh-git') { Remove-Module 'posh-git' -ErrorAction:SilentlyContinue }
                Set-OMPProfileSetting -Name:OMPGitOutput -Value:$Name
            }
        }

        Write-Verbose "$($FunctionName): End."
    }
}



Function Set-OMPProfileSetting {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Set-OMPProfileSetting.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Mandatory = $true)]
        $Value
    )
    dynamicparam {
        # Create dictionary
        $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ValidOMPProfileSettings = ($Script:OMPProfile).keys

        $NewParamSettings = @{
            Name = 'Name'
            Type = 'string'
            ValidateSet = $ValidOMPProfileSettings
            HelpMessage = "The setting to update the value of."
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
    process {
        # Pull in the dynamic parameters first
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

        try {
            Write-Verbose "$($FunctionName): Attempting to update the $Name Setting to be $Value."
            Write-Verbose "$($FunctionName): Original value of $($Name) - $($Script:OMPProfile[$Name])"
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Set-OMPTheme.md
    #>
    [CmdletBinding()]
	param (
        [Parameter()]
        [switch]$NoProfileUpdate,
        [Parameter()]
        [switch]$Safe
    )

    dynamicparam {
        # Create dictionary
        $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ThemesPath = Join-Path $Script:ModulePath "themes"
        $ValidThemes = @(Get-ChildItem -Path $ThemesPath -File -Filter '*.ps1').BaseName
        $NewParamSettings = @{
            Name = 'Name'
            Position = 0
            Type = 'string'
            ValidateSet = $ValidThemes
            HelpMessage = 'The theme to load. Will be applied immediately'
            ValueFromPipeline = $true
            ValueFromPipelineByPropertyName = $true
        }
        if ($null -ne $Script:OMPProfile['Theme']) {
            $NewParamSettings.ParameterDefaultValue = $Script:OMPProfile['Theme']
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
        $errmsg = $null
    }

    Process {
        if ($PSBoundParameters.ContainsKey('Name')) {
            try {
                if ($null -ne $PSBoundParameters['Name']) {
                    # Pull in the dynamic parameters first
                    New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters
                }
            }
            catch {}
        }

        if ([string]::IsNullOrEmpty($Name)) {
            Write-Output 'No theme specified, restoring the original PowerShell prompt and removing current theme'
            Restore-OMPConsolePrompt
            Restore-OMPConsoleTitle
            Restore-OMPConsoleColor
        }
        else {
            $ThemeScriptPath = (Join-Path $Script:ModulePath "themes\$Name.ps1")
            if (Test-Path $ThemeScriptPath) {
                Restore-OMPConsolePrompt
                Restore-OMPConsoleTitle
                Restore-OMPConsoleColor
                Write-Verbose "Loading theme file: $ThemeScriptPath"
                $script = (Get-Content $ThemeScriptPath -Raw)
                try {
                    $sb = [Scriptblock]::create(".{$script}")
                    Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
                    if (-not ([string]::IsNullOrEmpty($errmsg))) {
                        Write-Verbose "Errors occurred loading $ThemeScriptPath. Errors returned were $errmsg"
                        if ($Safe) {
                            Write-Warning "Errors were found on the error stream when loading the theme and the safe option was set, NOT saving this theme as the theme for this profile."
                            return
                        }
                    }

                    Set-OMPProfileSetting -Name 'Theme' -Value $Name
                }
                catch {
                    Write-Warning "Unable to load theme file $ThemeScriptPath"
                    Write-Warning "Errors reported - $errmsg"
                    throw
                }
            }
            else {
                Throw "Theme with the name $Name was not found (somehow)!"
            }
        }

        if (-not $NoProfileUpdate) {
            $Script:OMPProfile['Theme'] = $Name
            Export-OMPProfile
        }

        Write-Verbose "$($FunctionName): End."
    }
}


Function Set-OMPWindowTitle {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Set-OMPWindowTitle.md
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
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Show-OMPHelp.md
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


function Show-OMPStatus {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Show-OMPStatus.md
    #>

    [CmdletBinding()]
    param ()

    $Status = @'
Current OhMyPsh Profile: {{Profile}}
Loaded Plugins: {{Plugins}}
'@ -replace '{{Profile}}', $Script:OMPProfileExportFile -replace '{{Plugins}}', ($Script:OMPState['PluginsLoaded'] -join ', ')

    Write-Output $Status
}


Function Test-OMPConsoleHasANSI {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Test-OMPConsoleHasANSI.md
    #>

    # Powershell ISE don't support ANSI, and this test will print ugly chars
    if($host.PrivateData.ToString() -eq 'Microsoft.PowerShell.Host.ISE.ISEOptions') {
        return $false
    }

    # To test is console supports ANSI, we will print an ANSI code
    # and check if cursor postion has changed. If it has, ANSI is not
    # supported
    $oldPos = $host.UI.RawUI.CursorPosition.X

    Write-Host -NoNewline "$([char](27))[0m" -ForegroundColor ($host.UI.RawUI.BackgroundColor);

    $pos = $host.UI.RawUI.CursorPosition.X

    if($pos -eq $oldPos) {
        return $true
    }
    else {
        # If ANSI is not supported, let's clean up ugly ANSI escapes
        Write-Host -NoNewLine ("`b" * 4)
        return $false
    }
}


function Test-OMPInAGitRepo {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Test-OMPInAGitRepo.md
    #>

    if ((Test-Path ".git") -eq $TRUE) {
        return $TRUE
    }

    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + '/.git'
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $TRUE
        } else {
            $checkIn = $checkIn.parent
        }
    }

    return $FALSE
}



function Test-OMPIsElevated {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Test-OMPIsElevated.md
    #>

    [CmdletBinding()]
    param(
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    process {
    }
    end {
        switch ( Get-OMPOSPlatform -ErrorVariable null ) {
            'Linux' {
                # Add me!
            }
            'OSX' {
                # Add me!
            }
            Default {
                if (([System.Environment]::OSVersion.Version.Major -gt 5) -and ((New-object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
                    return $true
                }
                else {
                    return $false
                }
            }
        }
        Write-Verbose "$($FunctionName): End."
    }
}



Function Test-OMPProfileSetting {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Test-OMPProfileSetting.md
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [String]$Name
    )
    Process {
        if (($Script:OMPProfile).Keys -contains $Name ) {
            $true
        }
        else {
            $false
        }
    }
}



function Write-OMPGitStatus {
    <#
    .EXTERNALHELP OhMyPsh-help.xml
    .LINK
        https://github.com/zloeber/OhMyPsh/tree/master/release/0.0.7/docs/Functions/Write-OMPGitStatus.md
    #>

    switch ($Script:OMPProfile['OMPGitOutput']) {
        'posh-git' {
            Write-VcsStatus
        }
        'psgit' {
            Write-VcsStatus
        }
        Default {
            # Script or other method
            if (Test-OMPInAGitRepo) {
                $status = Get-OMPGitStatus
                $currentBranch = Get-OMPGitBranchName

                Write-Host '[' -nonewline -foregroundcolor Yellow
                Write-Host $currentBranch -nonewline

                $gitstatus = ' +' + $status["added"] + ' ~' + $status["modified"] + ' -' + $status["deleted"] + ' !' + $status["untracked"] + ']'
                Write-Host $gitstatus -foregroundcolor Yellow -NoNewline
            }
        }
    }
}



## Post-Load Module code ##

# These are core settings which we will not allow to ever get removed
$Script:OMPProfileCoreSettings = @(
    'AutoLoadModules',
    'AutoInstallModules',
    'Plugins',
    'PersonalFunctions',
    'Theme',
    'UnloadModulesOnExit',
    'OMPRunCount',
    'OMPPluginRootPaths',
    'OMPDebug',
    'OMPGitOutput'
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
    # Preferred git status method. Used in prompts, specifically in Write-OMPGitStatus. Can be:
    # posh-git (module), psgit (module), script/other (no module, use the crappy baked in scripts with this module instead).
    OMPGitOutput = 'script'
    OMPModuleInstallSplat = @{
        'AllowClobber' = $true
        'Force' = $true
        'Scope' = 'CurrentUser'
    }
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
# used for this purpose. This combined with Get-OMPState can speed up some operations.
# This is only able to be updated by OMP functions.
$OMPState = @{
    PluginsLoaded = @()
    ModulesAlreadyLoaded = @((Get-Module).Name)
    Platform = Get-OMPOSPlatform
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
    if (-not [string]::IsNullOrEmpty($Script:OMPProfile['Theme'])) {
        Set-OMPTheme -Name $Theme -NoProfileUpdate
        Write-Verbose "Theme Loaded: $($Theme)"
    }
}
catch {
    Write-Warning "Unable to load the following theme: $($Theme)"
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
    Restore-OMPConsolePrompt
    Restore-OMPOriginalTabCompletion
    Restore-OMPOriginalPSDefaultParameter
    Restore-OMPOriginalAlias
    Restore-OMPConsoleTitle
    Restore-OMPConsoleColor
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

$ThisModuleLoaded = $true


