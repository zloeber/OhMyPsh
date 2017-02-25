#Requires -Version 5
<#
.SYNOPSIS
Create the base framework for a module for building with PSModuleBuild
.DESCRIPTION
Create the base framework for a module for building with PSModuleBuild
.PARAMETER ModuleName
The short name of your module project (ie. MyModule)
.PARAMETER ModuleWebsite
The website of your module project (ie. https://www.github.com/myname/mymodule)
.PARAMETER ModuleAuthor
The author of this module (ie. My Name)
.PARAMETER ModuleDescription
A short description of this module.
.PARAMETER ModuleTags
Meta tags for your module, separated by commas (ie. API integration, web scraping, Coolness)
.PARAMETER GithubRepo
An already created github repo for your project (ie. https://github.com/MyName/MyModule.git )
.EXAMPLE
.\Initialize.ps1
.NOTES
Author: Zachary Loeber
Site: http://www.the-little-things.net/
Version History
1.0.0 - Initial release
#>
Param (
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = 'The short name of your module project (ie. MyModule)')]
    [string]$ModuleName,
    [Parameter(Position = 1, Mandatory = $true, HelpMessage = 'The website of your module project (ie. https://www.github.com/myname/mymodule)')]
    [string]$ModuleWebsite,
    [Parameter(Position = 2, Mandatory = $true, HelpMessage = 'The author of this module (ie. My Name)')]
    [string]$ModuleAuthor,
    [Parameter(Position = 3, Mandatory = $true, HelpMessage = 'A short description of this module.')]
    [string]$ModuleDescription,
    [Parameter(Position = 4, Mandatory = $true, HelpMessage = 'Meta tags for your module, separated by commas (ie. API integration, web scraping, Coolness)')]
    [string]$ModuleTags,
    [Parameter(Position = 5, Mandatory = $false, HelpMessage = 'An already created github repo for your project (ie. https://github.com/MyName/MyModule.git )')]
    [string]$GithubRepo
)

$IBParam = @{
    'ModuleName' = $ModuleName
    'ModuleWebsite' = $ModuleWebsite
    'ModuleAuthor' = $ModuleAuthor
    'ModuleDescription' = $ModuleDescription
    'ModuleTags' = $ModuleTags
}

if (-not [string]::IsNullOrEmpty($GithubRepo)) {
        $IBParam.GithubRepo = $GithubRepo
}

# Install InvokeBuild module if it doesn't already exist
if ((get-module InvokeBuild -ListAvailable) -eq $null) {
    Write-Host -NoNewLine "      Installing InvokeBuild module"
    $null = Install-Module InvokeBuild
    Write-Host -ForegroundColor Green '...Installed!'
}
if (get-module InvokeBuild -ListAvailable) {
    Write-Host -NoNewLine "      Importing InvokeBuild module"
    Import-Module InvokeBuild -Force
    Write-Host -ForegroundColor Green '...Loaded!'
}
else {
    throw 'How did you even get here?'
}

# Kick off the new module scaffolding creation process build
try {
    Invoke-Build -File PSModuleBuild.createframework.ps1 @IBParam

    # Ensure we cannot run this initialization process again
	Remove-item .\PSModuleBuild.createframework.ps1 -Force

    Write-Host ''
    Write-Host ''
    Write-Host -Foregroundcolor Yellow 'Module framework has been created! Please review and make any relevant changes to the automatically generated psd1 manifest file.'
    Write-Host ''
    Write-Host -Foregroundcolor Yellow 'You can now start populating module in the following locations:'
    Write-Host -Foregroundcolor Yellow '    src\private    - Any private functions should be individually included in this directory.'
    Write-Host -Foregroundcolor Yellow '    src\public     - Any public functions should be individually included in this directory.'
    Write-Host -Foregroundcolor Yellow '    src\other\PreLoad.ps1    - Load this code before any other code in this module. This will carry over to  your final build as well.'
    Write-Host -Foregroundcolor Yellow '    src\other\PostLoad.ps1   - Load this code after any other code in this module. This will carry over to  your final build as well.'
    Write-Host ''
    Write-Host -Foregroundcolor Yellow 'When you are ready to release an initial version of your module run the included build script: .\Build.ps1'
    Write-Host ''
    Write-Host -Foregroundcolor Yellow 'For more information on what tasks can be performed with the included build script please visit https://github.com/zloeber/PSModuleBuild'
    Write-Host ''
    Write-Host -ForegroundColor:Cyan 'Note: The original PSModuleBuild.createframework.ps1 build file has been deleted. Go ahead and delete Initialize.ps1 now to clean up your project directory and complete this process.'
}
catch {
    # If it fails then show the error
    Write-Host -ForegroundColor Red 'Build Failed with the following error:'
    Write-Output $_
}
finally {
    #  Try to clean up the environment
    Write-Host ''
    Write-Host 'Attempting to clean up the session (loaded modules and such)...'
    Remove-Module InvokeBuild
}