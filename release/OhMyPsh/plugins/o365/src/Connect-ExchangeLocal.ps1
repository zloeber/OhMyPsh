Function Global:Connect-ExchangeLocal([string]$Server = "" ) {
    $URI = 'http://' + $Server + '/PowerShell/'
#    $proxysettings = New-PSSessionOption -ProxyAccessType IEConfig
    $upn = ([ADSISEARCHER]"samaccountname=$($env:USERNAME)").Findone().Properties.userprincipalname
    $creds = Get-Credential -UserName $upn -Message "Enter password for $upn"
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $URI -Credential $creds -Authentication Kerberos -AllowRedirection -Verbose #-SessionOption $proxysettings

    Import-PSSession $session -AllowClobber
    Write-Output "`n`n`nDon't forget to 'Remove-PSSession `$session' when you're done"
}