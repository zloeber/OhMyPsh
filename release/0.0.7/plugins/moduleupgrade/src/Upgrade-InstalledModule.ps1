#Requires -Version 5
Function Global:Upgrade-InstalledModule {
    <#
    .SYNOPSIS
        A small wrapper for PowerShellGet to upgrade installed modules.
    .DESCRIPTION
        A small wrapper for PowerShellGet to upgrade installed modules.
    .PARAMETER ModuleName
        Show modules which would get upgraded.
    .PARAMETER Silent
        Do not show progress bar.
    .PARAMETER Force
        Force an upgrade without any confirmation prompts.
    .EXAMPLE
        PS> Upgrade-InstalledModule -Force

        Updates modules installed via PowerShellGet. Shows a progress bar.
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

        function Get-PIIsElevated {
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
        $ThisUser = [Environment]::GetEnvironmentVariable('USERNAME')

        if (Get-PIIsElevated) {
            Write-Verbose "Adding all module paths to allowed module upgrade paths list..."
            $ModulePaths += [Environment]::GetEnvironmentVariable('PSModulePath','Machine').split(";")
        }
        else {
            Write-Verbose "Adding only user module paths to allowed module upgrade paths list..."
            $ModulePaths += [Environment]::GetEnvironmentVariable('PSModulePath').split(";") | Where {$_ -like "*$ThisUser*"}
        }
    }

    Process {
        $Count = 0

        if (-not $Silent) {
            Write-Progress -Activity "Retrieving installed modules" -PercentComplete 1 -Status "Processing"
        }
        $InstalledModules = @(Get-InstalledModule $ModuleName | Where {$ModulePaths -contains ($_.InstalledLocation -replace "\\$($_.Name)\\$($_.Version)",'')})
        $TotalMods = $InstalledModules.Count
        ForEach ($Mod in $InstalledModules) {
            Write-Verbose "Looking for updates to '$Mod.Name'..."
            $count++
            if (-not $Silent) {
                $PercentComplete = [math]::Round((100*($count/$TotalMods)),0)
                Write-Progress -Activity "Processing Module $($Mod.Name)" -PercentComplete $PercentComplete -Status "Checking Module For Updates"
            }
            $OnlineModule = Find-Module $Mod.Name
            if ($OnlineModule.Version -gt $Mod.Version) {
                if ($pscmdlet.ShouldProcess("Upgraded module $($Mod.Name) from $($Mod.Version.ToString()) to $($OnlineModule.Version.ToString())",
                "Upgrade module $($Mod.Name) from $($Mod.Version.ToString()) to $($OnlineModule.Version.ToString())?",
                "Upgrading module $($Mod.Name)")) {
                    if($Force -Or $PSCmdlet.ShouldContinue("Are you REALLY sure you want to upgrade '$($Mod.Name)'?",
                    "Upgrading module '$($Mod.Name)'",
                    [ref]$YesToAll,
                    [ref]$NotoAll)) {
                        if (-not $Silent) {
                            Write-Progress -Activity "Upgrading Module $($Mod.Name)" -PercentComplete $PercentComplete -Status "Upgrading Module"
                        }
                        Update-Module $Mod.Name -Force -Confirm:$false
                    }
                }
            }
        }
    }
}