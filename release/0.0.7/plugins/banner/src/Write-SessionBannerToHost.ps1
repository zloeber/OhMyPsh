function Global:Write-SessionBannerToHost {
    [CmdletBinding()]
    param(
        [int]$Spacer = 1,
        [switch]$AttemptAutoFit
    )
    Begin {
        $HasANSI = if (Test-OMPConsoleHasANSI) {$true} else {$false}
        $Spaces = (' ' * $Spacer)
        $OSPlatform = Get-OMPOSPlatform -ErrorVariable null

        if ($AttemptAutoFit) {
            try {
                $IP = @(Get-OMPIPAddress)[0]
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
            $UptimeBoot = "Uptime (hardware boot): $(Get-OMPSystemUptime)"
            $UptimeResume = Get-OMPSystemUptime -FromSleep
            if ($UptimeResume) {
                $UptimeResume = "Uptime (system resume): $($UptimeResume)"
            }
        }
        else {
            # Collect all the banner data
            try {
                $IP = @(Get-OMPIPAddress)[0]
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

            $OSPlatform = Get-OMPOSPlatform -ErrorVariable null
            $PSExecPolicy = Get-ExecutionPolicy
            $PSVersion = $PSVersionTable.PSVersion.Major
            $CompName = $env:COMPUTERNAME
            $UserDomain = $env:UserDomain
            $LogonServer = $env:LOGONSERVER -replace '\\'
            $UserName = $env:UserName
            $UptimeBoot = Get-OMPSystemUptime
            $UptimeResume = Get-OMPSystemUptime -FromSleep
        }

        $PSProcessElevated = 'TRUE'
        if ($OSPlatform -eq 'Windows') {
            if (Test-OMPIsElevated) {
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
        if ($AttemptAutoFit -or (-not $HasANSI)) {
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