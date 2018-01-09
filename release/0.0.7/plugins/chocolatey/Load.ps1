$PreLoad = {
    # Chocolatey profile
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile" -Scope Global
    }
}

$PostLoad = {}
$Config = {}
$Shutdown = {}
$Unload = {}