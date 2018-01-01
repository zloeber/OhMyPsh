function Get-OMPTheme {
    <#
    .Synopsis
    Shows themes and their load state.
    .DESCRIPTION
    Shows themes and their load state.
    .PARAMETER Name
    The theme name. If nothing is passed all themes are listed.

    .EXAMPLE
    Get-OMPTheme

    Shows all OhMyPsh themes and if it is loaded or not.
    .OUTPUTS
    OMP.ThemeStatus
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    .NOTES
    Author: Zachary Loeber
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