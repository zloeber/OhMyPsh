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
    .LINK
       https://www.github.com/zloeber/OhMyPsh
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