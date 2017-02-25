#Requires -Modules Pester

<#
    This pester test verifies the files in the specified path do not contain sensitive information.

    Example:
    Invoke-Pester -Script @{Path = '.\src\tests\SensitiveTermScan.Tests.ps1'; Parameters = @{ Path = 'C:\Users\zloeber\Dropbox\Zach_Docs\Projects\Git\PSAD'; Terms = @('mydomainname.com', 'myservername') }}
#>

[CmdletBinding()]
Param(
    [Parameter(HelpMessage = 'Path to the files to scan.')]
    [string]$Path,
    [Parameter(HelpMessage = 'Terms to scan for.')]
    [string[]]$Terms
)

if (($ManifestPath.EndsWith('psd1')) -and (Test-Path $ManifestPath)) {
    $ModulePath = $ManifestPath
}
elseif ((-not [string]::IsNullOrEmpty($ManifestPath)) -and (Test-Path $ManifestPath)) {
    $ModulePath = (Get-ChildItem -Path $ManifestPath -Filter '*.psd1' -File | Select-Object -First 1).FullName
}
elseif  ([string]::IsNullOrEmpty($ManifestPath)) {
    # Otherwise we are running the test against the module found above the src\tests directory
    $ModulePath = (Get-ChildItem -Path ..\..\ -Filter '*.psd1' -File | Select-Object -First 1).FullName
}
else {
    $ModulePath = $ManifestPath
}

# Grab the short module name
$ModuleName =  (Split-Path $ManifestPath -Leaf).Split('.')[0]

# If no author or website are being passed to check against then assume we are using psmodulebuild variables
if (([string]::IsNullOrEmpty($Author)) -or ([string]::IsNullOrEmpty($Website))) {
    Get-ChildItem -Path ..\..\*.buildenvironment.ps1 | Select-Object -First 1 | Foreach-Object {
        Write-Output "Dot sourcing build environment file $($_.FullName)"
        . $_.FullName
    }
    $Author = $Script:BuildEnv['ModuleAuthor']
    $Website = $Script:BuildEnv['ModuleWebsite']
}

Describe 'Module Manifest Content' {
    Context "Testing $ModulePath" {
        It 'should be a valid module manifest file' {
            { 
                $Script:Manifest = Test-ModuleManifest -Path $ModulePath -ErrorAction Stop -WarningAction SilentlyContinue
            } |  Should Not Throw
        }

        It 'should have a valid rootmodule value' {
            $Script:Manifest.RootModule | Should BeExactly "$ModuleName.psm1"
        }

        It 'should have a valid version' {
            $Script:Manifest.Version -as [Version] | Should Not BeNullOrEmpty
        }

        It 'should have a valid description' {
            $Script:Manifest.Description | Should Not BeNullOrEmpty
        }

        It 'should have a valid GUID' {
            $Script:Manifest.Guid | Should BeLike '????????-????-????-????-????????????'
        }

        It 'should have a valid author' {
            $Script:Manifest.Author | Should BeExactly $Author
        }

        It 'should have a Copyright value' {
            $Script:Manifest.Copyright | Should Not BeNullOrEmpty
        }

        It 'should have a valid PowerShellVersion value' {
            $Script:Manifest.PowerShellVersion | Should Not BeNullOrEmpty
        }
               It 'should have a valid project website' {
            # Act
            $actual = $Script:Manifest.PrivateData

            # Assert
            $actual.PSData.ProjectUri | Should BeExactly $Website
        }

        It 'should have a valid license URL' {
            # Arrange
            if ($LicenceURI) {
                $expectLicenseUri = $LicenceURI
            }
            else {
                $expectLicenseUri = "$Website/master/LICENSE.md"
            }

            $Script:Manifest.LicenseUri | Should BeExactly $expectLicenseUri
        }

        if ($Tags.count -gt 0) {
            It "should have these tags: $($Tags -join ',')" {
                Compare-Object $Script:Manifest.Tags $Tags | Should Be $Null
            }
        }
        else {
            It 'should have some tags' {
                @($Script:Manifest.Tags).Count -gt 0 | Should Be $true
            }
        }
    }
}