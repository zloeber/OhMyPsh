function Global:Write-SessionBannerToHost {
    [CmdletBinding()]
    param(
        [int]$Spacer = 1,
        [switch]$AttemptAutoFit
    )
    Begin {
        # Retreive the current OS platform based on the existence of some known default variables in Powershell 6.
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

        function Get-PIIPAddress {
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
        }
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
        function Get-PIUptime {
            # Retreive platform independant uptime informaton (should run on both linux and windows properly)
            param(
                [switch]$FromSleep
            )
            switch ( Get-OSPlatform -ErrorVariable null ) {
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

        $Spaces = (' ' * $Spacer)
        $OSPlatform = Get-OSPlatform -ErrorVariable null

        if ($AttemptAutoFit) {
            try {
                $IP = @(Get-PIIPAddress)[0]
                if ([string]::isnullorempty($IP)) {
                    $IPAddress = 'IP: Offline'
                    $IPGateway = 'GW: Offline'
                }
                else {
                    $IPAddress = "IP: $(@($IP.IP)[0])/$($IP.Prefix)"
                    $IPGateway = "GW: $($IP.Gateway)"
                }
            }
            catch {
                $IPAddress = 'IP: NA'
                $IPGateway = 'GW: NA'
            }

            $PSExecPolicy = "Exec Pol: $(Get-ExecutionPolicy)"
            $PSVersion = "PS Ver: $($PSVersionTable.PSVersion.Major)"
            $CompName = "Computer: $($env:COMPUTERNAME)"
            $UserDomain = "Domain: $($env:UserDomain)"
            $LogonServer = "Logon Sever: $($env:LOGONSERVER -replace '\\')"
            $UserName = "User: $($env:UserName)"
            $UptimeBoot = "Uptime (hardware boot): $(Get-PIUptime)"
            $UptimeResume = Get-PIUptime -FromSleep
            if ($UptimeResume) {
                $UptimeResume = "Uptime (system resume): $($UptimeResume)"
            }
        }
        else {
            # Collect all the banner data
            try {
                $IP = @(Get-PIIPAddress)[0]
                if ([string]::isnullorempty($IP)) {
                    $IPAddress = 'Offline'
                    $IPGateway = 'Offline'
                }
                else {
                    $IPAddress = "$(@($IP.IP)[0])/$($IP.Prefix)"
                    $IPGateway = "$($IP.Gateway)"
                }
            }
            catch {
                $IPAddress = 'NA'
                $IPGateway = 'NA'
            }

            $OSPlatform = Get-OSPlatform -ErrorVariable null
            $PSExecPolicy = Get-ExecutionPolicy
            $PSVersion = $PSVersionTable.PSVersion.Major
            $CompName = $env:COMPUTERNAME
            $UserDomain = $env:UserDomain
            $LogonServer = $env:LOGONSERVER -replace '\\'
            $UserName = $env:UserName
            $UptimeBoot = Get-PIUptime
            $UptimeResume = Get-PIUptime -FromSleep
        }

        $PSProcessElevated = 'TRUE'
        if ($OSPlatform -eq 'Windows') {
            if (Get-PIElevatedStatus) {
                $PSProcessElevated = 'TRUE'
            }
            else {
                $PSProcessElevated = 'FALSE'
            }
        }
        else {
            # Code to determine if you are a root user or not...
        }

        if ($AttemptAutoFit) {
            $PSProcessElevated = "Elevated: $($PSProcessElevated)"
        }
    }

    Process {}
    End {
        if ($AttemptAutoFit) {
            Write-Host ("{0,-25}$($Spaces)" -f $IPAddress) -noNewline
            Write-Host ("{0,-25}$($Spaces)" -f $UserDomain) -noNewline
            Write-Host ("{0,-25}$($Spaces)" -f $LogonServer) -noNewline
            Write-Host ("{0,-25}$($Spaces)" -f $PSExecPolicy)

            Write-Host ("{0,-25}$($Spaces)" -f $IPGateway) -noNewline
            Write-Host ("{0,-25}$($Spaces)" -f $CompName) -noNewline
            Write-Host ("{0,-25}$($Spaces)" -f $UserName) -noNewline
            Write-Host ("{0,-25}$($Spaces)" -f $PSVersion)
            Write-Host
            Write-Host $UptimeBoot
            if ($UptimeResume) {
                Write-Host $UptimeResume
            }
        }
        else {
            Write-Host "Dom:" -ForegroundColor Green  -nonewline
            Write-Host $UserDomain -ForegroundColor Cyan  -nonewline
            Write-Host "$Spaces|$Spaces" -ForegroundColor White  -nonewline

            Write-Host "Host:"-ForegroundColor Green  -nonewline
            Write-Host $CompName -ForegroundColor Cyan  -nonewline
            Write-Host "$Spaces|$Spaces" -ForegroundColor White  -nonewline

            Write-Host "Logon Svr:" -ForegroundColor Green -nonewline
            Write-Host $LogonServer -ForegroundColor Cyan
            #Write-Host "$Spaces|$Spaces" -ForegroundColor Yellow


            Write-Host "PS:" -ForegroundColor Green -nonewline
            Write-Host $PSVersion -ForegroundColor Cyan  -nonewline
            Write-Host "$Spaces|$Spaces" -ForegroundColor White -nonewline

            Write-Host "Elevated:" -ForegroundColor Green -nonewline
            if ($PSProcessElevated -eq 'TRUE') {
                Write-Host $PSProcessElevated -ForegroundColor Red -nonewline
            }
            else {
                Write-Host $PSProcessElevated -ForegroundColor Cyan -nonewline
            }
            Write-Host "$Spaces|$Spaces" -ForegroundColor White  -nonewline

            Write-Host "Execution Policy:" -ForegroundColor Green -nonewline
            Write-Host $PSExecPolicy -ForegroundColor Cyan

            # Line 2
            Write-Host "User:" -ForegroundColor Green  -nonewline
            Write-Host $UserName -ForegroundColor Cyan  -nonewline
            Write-Host "$Spaces|$Spaces" -ForegroundColor White  -nonewline

            Write-Host "IP:" -ForegroundColor Green  -nonewline
            Write-Host $IPAddress -ForegroundColor Cyan -nonewline
            Write-Host "$Spaces|$Spaces" -ForegroundColor White -nonewline

            Write-Host "GW:" -ForegroundColor Green -nonewline
            Write-Host $IPGateway -ForegroundColor Cyan

            Write-Host

            # Line 3
            Write-Host "Uptime (hardware boot): " -nonewline -ForegroundColor Green
            Write-Host $UptimeBoot -ForegroundColor Cyan

            # Line 4
            if ($UptimeResume) {
                Write-Host "Uptime (system resume): " -nonewline -ForegroundColor Green
                Write-Host $UptimeResume -ForegroundColor Cyan
            }
        }
    }
}
