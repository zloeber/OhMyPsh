function Global:Connect-ExchangeOnline {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage='Credentials to connect with.' )]
        [alias('Creds')]
        [Management.Automation.PSCredential]$Credential,
        [Parameter(HelpMessage='Prompt for different connection settings.' )]
        [switch]$Interactive
    )

    if ($null -eq $Credential) {
        $upn = ([ADSISEARCHER]"samaccountname=$($env:USERNAME)").Findone().Properties.userprincipalname
        $creds = Get-Credential -UserName $upn -Message "Enter password for $upn"
    }
    else {
        $creds = $Credential
    }

    $SessionOptions = New-PSSessionOption -ProxyAccessType IEConfig -SkipRevocationCheck -SkipCACheck -SkipCNCheck

    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $creds -Authentication Basic -AllowRedirection -SessionOption $SessionOptions

    $ImportParam = @{}

    if ($Interactive) {
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes',''
        $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No',''
        $choices = [System.Management.Automation.Host.ChoiceDescription[]]($no,$yes)
        $result = $Host.UI.PromptForChoice('Prefix Commands','Do you want to prefix all imported commands with o365 (useful if you are accessing both on premise and cloud environments?',$choices,0)
        $AddPrefix = ($result -eq $true)

        If ( $AddPrefix ) {
            $ImportParam.Prefix = 'o365'
        }
    }

    Import-Module (Import-PSSession $session @ImportParam -AllowClobber) -Global
    if ($Interactive) {
        Write-Output "`n`n`nDon't forget to 'Remove-PSSession `$session' when you're done"
    }

    # If the msonline module is available then ask if we want to load it as well
    if  ((get-module msonline -ListAvailable) -and $Interactive) {
        $result = $Host.UI.PromptForChoice('MSOL','Connect to MSOL as well?',$choices,0)
        $MSOL = ($result -eq $true)

        if ( $MSOL ) {
            import-module msonline -ErrorAction SilentlyContinue
            if ((get-module | Where-Object {$_.Name -eq 'msonline'}) -ne $null) {
                Connect-MsolService -Credential $creds }
            else {
                Write-Warning 'Unable to load the MSOnline powershell module!'
            }
        }
    }

}