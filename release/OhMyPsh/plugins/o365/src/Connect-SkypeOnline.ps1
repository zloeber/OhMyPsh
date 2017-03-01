function Global:Connect-SkypeOnline{
    [CmdLetBinding()]
    param()

    try {
        Import-Module SkypeOnlineConnector
        $proxysettings = New-PSSessionOption -ProxyAccessType IEConfig
        $upn = ([ADSISEARCHER]"samaccountname=$($env:USERNAME)").Findone().Properties.userprincipalname
        $creds = Get-Credential -UserName $upn -Message "Enter password for $upn"
        $session = New-CsOnlineSession -Credential $creds -Verbose -SessionOption $proxysettings
        Import-PSSession $session -AllowClobber
    }
    catch {
        throw
    }
}