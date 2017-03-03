function Test-IsAdmin {
    if (([System.Environment]::OSVersion.Version.Major -gt 5) -and ((New-object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
        return $true
    }
    else {
        return $false
    }
}