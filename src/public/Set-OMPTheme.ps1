Function Set-OMPTheme {
    <#
    .SYNOPSIS
    Sets the theme.
    .DESCRIPTION
    Sets the theme.
    .PARAMETER Name
    Name of the Theme
    .PARAMETER NoProfileUpdate
    Skip updating the profile
    .PARAMETER Force
    Force update the profile regardless of errors returned when loading a theme.
    .EXAMPLE
    PS> Set-OMPTheme -Name 'base'
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://github.com/zloeber/ohmypsh
    #>
    [CmdletBinding()]
	param (
        [Parameter()]
        [switch]$NoProfileUpdate,
        [Parameter()]
        [switch]$Force
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
        try {
            if ($null -ne $PSBoundParameters) {
                # Pull in the dynamic parameters first
                New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters
            }
        }
        catch {}

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
                        Write-Warning "Errors occurred loading $ThemeScriptPath. Errors returned were $errmsg"
                        if ($Force) {
                            Write-Warning "Forcing the OhMyPsh profile to update with the theme regardless of errors returned during processing!"
                            Set-OMPProfileSetting -Name 'Theme' -Value $Name
                        }
                    }
                    else {
                        Set-OMPProfileSetting -Name 'Theme' -Value $Name
                    }
                }
                catch {
                    Write-Warning "Unable to load theme file $ThemeScriptPath"
                    Write-Warning "Errors reported - $errmsg"
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