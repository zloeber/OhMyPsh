#Requires -Version 5
function Global:Remove-OldModule {
    <#
    .SYNOPSIS
        A small wrapper for PowerShellGet to remove all older installed modules.
    .DESCRIPTION
        A small wrapper for PowerShellGet to remove all older installed modules.
    .PARAMETER ModuleName
        Name of a module to check and remove old versions of. Default is all modules ('*')
    .PARAMETER Silent
        Do not show progress bar.
    .PARAMETER Force
        Force removal without any confirmation prompts.
    .EXAMPLE
        PS> Remove-OldModules

        Removes old modules installed via PowerShellGet.

    .EXAMPLE
        PS> Remove-OldModules -whatif

        Shows what old modules might be removed via PowerShellGet.

    .NOTES
        Author: Zachary Loeber
        Site: http://www.the-little-things.net/


        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding( SupportsShouldProcess=$True, ConfirmImpact='Medium' )]
    Param (
        [Parameter(HelpMessage = 'Name of a module to check and remove old versions of.')]
        [string]$ModuleName = '*',
        [Parameter(HelpMessage = 'Force upgrade modules without confirmation.')]
        [Switch]$Force,
        [Parameter(HelpMessage = 'Do not write progress.')]
        [Switch]$Silent
    )

    Begin {
        try {
            Import-Module PowerShellGet
        }
        catch {
            Write-Warning 'Unable to load PowerShellGet. This script only works with PowerShell 5 and greater.'
            return
        }

        function Get-OSPlatform {
            [CmdletBinding()]
            param(
                [Parameter()]
                [Switch]$IncludeLinuxDetails
            )

            #$Runtime = [System.Runtime.InteropServices.RuntimeInformation]
            #$OSPlatform = [System.Runtime.InteropServices.OSPlatform]

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
        }

        function Get-PIElevatedStatus {
            # Platform independant function that returns true if you are running as an elevated account, false if not.
            switch ( Get-OSPlatform -ErrorVariable null ) {
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
        }

        $YesToAll = $false
        $NoToAll = $false
        $ModulePaths = @()
        if ([Environment]::GetEnvironmentVariable('PSModulePath','User')) {
            $ModulePaths += [Environment]::GetEnvironmentVariable('PSModulePath','User').split(";")
        }

        if (Get-PIElevatedStatus) {
            Write-Verbose "Adding computer module paths to allowed module upgrade paths list..."
            $ModulePaths += [Environment]::GetEnvironmentVariable('PSModulePath','Machine').split(";")
        }

        $ModulesToRemove = @()
    }

    Process {
        $Count = 0

        Get-InstalledModule $ModuleName | Where {$ModulePaths -contains ($_.InstalledLocation -replace "\\$($_.Name)\\$($_.Version)",'')} | ForEach-Object {
            Write-Verbose "Looking for older versions of '$Mod.Name'..."
            $Count++
            if (-not $Silent) {
                Write-Progress -Activity "Calculating removable modules" -PercentComplete ($Count % 100) -Status "Calculating"
            }
            $ThisModule = Get-InstalledModule $_.Name -AllVersions | Sort-Object Version
            If ($ThisModule.count -gt 1) {
                $ModulesToRemove += $ThisModule | Select-Object -First ($ThisModule.count - 1)
            }
        }

        $Count = 0
        $TotalMods = $ModulesToRemove.Count
        ForEach ($Mod in $ModulesToRemove) {
            $Ver = $Mod.Version.ToString()
            $Count++

            if ($pscmdlet.ShouldProcess("Remove module $($Mod.Name) - $($Ver)",
            "Remove module $($Mod.Name) - $($Ver)?",
            "Removing module $($Mod.Name) - $($Ver)")) {
                if($Force -Or $PSCmdlet.ShouldContinue("Are you REALLY sure you want to remove '$($Mod.Name) - $($Ver) '?",
                "Removing module '$($Mod.Name) - $($Ver)'",
                [ref]$YesToAll,
                [ref]$NotoAll)) {
                    if (-not $Silent) {
                        $PercentComplete = [math]::Round((100*($Count/$TotalMods)),0)
                        Write-Progress -Activity "Removing Old Module $($Mod.Name) (version: $($Ver))" -PercentComplete $PercentComplete -Status "Removing..."
                    }
                    Uninstall-Module $Mod.Name -RequiredVersion $Ver -Force -Confirm:$false
                }
            }
        }
    }
}