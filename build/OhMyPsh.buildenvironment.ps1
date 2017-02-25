param (
    [Parameter(HelpMessage = 'If you are initializing this file or want to force overwrite the persistent export data use this flag.')]
    [switch]$ForcePersist
)
<#
 Update $Script:BuildEnv to suit your PowerShell module build. These variables get dot sourced into 
 the build at every run and are exported to an external xml file for persisting through possible build
 engine upgrades.
#>

# If the variable is already defined then essentially do nothing. 
# Otherwise we create a baseline variable first in case this is a first time run, then
# check for an exported .xml file with persistent settings for any run thereafter
if ((Get-Variable 'BuildEnv' -ErrorAction:SilentlyContinue) -eq $null) {
    # Fill out each of the BuildEnv hash entries with your own values for this project
    $Script:BuildEnv = @{
        # The module we are building
        #   Example: 'FormatPowerShellCode'
        ModuleToBuild = 'OhMyPsh'

        # Project website (used for external help cab file definition) 
        # Example: 'https://github.com/zloeber/FormatPowershellCode' 
        ModuleWebsite = 'https://www.github.com/zloeber/OhMyPsh'

        # Some tags that describe your module. 
        # Example: @('Code Formatting', 'Module Creation', 'Build Scripts')
        ModuleTags = @('profile', 'console', 'shell', 'plugin', 'command_line')

        # Module Author
        ModuleAuthor = 'Zachary Loeber'

        # Module Author
        ModuleDescription = 'A PowerShell 5.0 console utility that uses a simple json configuration file to manage plugins, theming, module autoloading, module upgrading, module cleanup, and other chores so that you can be more productive in the shell.'

        # Options - These affect how your eventual build will be run.
        OptionFormatCode = $false
        OptionAnalyzeCode = $true
        OptionUnitTestCode = $true
        OptionCombineFiles = $true
        OptionTranscriptEnabled = $false
        OptionTranscriptLogFile = 'BuildTranscript.Log'

        # PlatyPS has been the cause of most of my build failures. This can help you isolate which functrion's CBH is causing you grief.
        OptionRunPlatyPSVerbose = $false

        # If you want to prescan and fail a build upon finding any proprietary strings 
        # enable this option and define some strings to scan for
        OptionScanSensitiveStrings = $false
        OptionScanSensitiveTerms = @()
        
        # Additional paths in the source module which should be copied over to the final build release
        AdditionalModulePaths = @()         # Example: @('.\libs','.\data')

        # Most of the following options you probably don't need to change
        BaseSourceFolder = 'src'        # Base source path
        PublicFunctionSource = "src\public"         # Public functions (to be exported by file name as the function name)
        PrivateFunctionSource = "src\private"        # Private function source
        OtherModuleSource = "src\other"        # Other module source
        BaseReleaseFolder = 'release'        # Releases directory.
        BuildToolFolder = 'build'        # Build tool path (these scripts are dot sourced)
        ScratchFolder = 'temp'        # Scratch path - this is where all our scratch work occurs. It will be cleared out at every run.

        # If you will be publishing to the PowerShell Gallery you will need a Nuget API key (can get from the website)
        # You should not actually enter this key here but should manually enter it in the OhMyPsh.buildenvironment.xml file
        NugetAPIKey = ''
    }

    ########################################
    # !! Please leave anything below this line alone !!
    ########################################
    $PersistentBuildFile = ".\$($BuildEnv['BuildToolFolder'])\OhMyPsh.buildenvironment.xml"

    # Load any persistent data (overrides anything in BuildEnv if the hash element exists)
    if ((Test-Path $PersistentBuildFile)) {
        $LoadedBuildEnv = Import-Clixml -Path $PersistentBuildFile
        ForEach ($Key in $LoadedBuildEnv.Keys) {
            if (@($Script:BuildEnv.Keys) -contains $Key) {
                $Script:BuildEnv[$Key] = $LoadedBuildEnv[$Key]
            }
            else {
                Write-Warning "$Key found in saved build environment xml but not in the BuildEnv hash! When this import is done the final contents will be re-exported and saved for future runs!"
                $BuildExport = $True
            }
        }
    }
    else {
        # No persistent file was found so we are going to create one
        $BuildExport = $True
    }
    
    # If we don't have a persistent file, we are forcing a persist, or properties were not the same between
    # the loaded xml and our defined BuildEnv file then push a new persistent file export.
    if ((-not (Test-path $PersistentBuildFile)) -or $BuildExport -or $ForcePersist) {
        Write-Output "Exporting the BuildEnv data!"
        $Script:BuildEnv | Export-Clixml -Path  $PersistentBuildFile -force
    }

    # If you will be attempting to autogenerate comment based help this is the base template that will be used
    # You need to leave the %%<string>%% tags to automatically be populated.
    $CBHTemplate = @'
    <#
    .SYNOPSIS
        TBD
    .DESCRIPTION
        TBD
    %%PARAMETER%%
    .EXAMPLE
        TBD
    .NOTES
        Author: %%AUTHOR%%
    .LINK
        %%LINK%%
    #>
'@ -replace '%%LINK%%',$BuildEnv['ModuleWebsite'] -replace '%%AUTHOR%%',$BuildEnv['ModuleAuthor']
}
