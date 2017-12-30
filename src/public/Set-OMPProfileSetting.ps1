Function Set-OMPProfileSetting {
    <#
    .SYNOPSIS
    Set one of the OMP settings.
    .DESCRIPTION
    Set one of the OMP settings.
    .PARAMETER Name
    Name of the setting
    .PARAMETER Value
    Value of the setting
    .EXAMPLE
    PS> Set-OMPSetting -Name 'SomeSetting' -Value 'somevalue'
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://github.com/zloeber/ohmypsh
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