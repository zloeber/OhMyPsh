$PreLoad = {}
$PostLoad = {}
$Config = {
    # A few example psdefaultparametervalues to start with
    $Global:PSDefaultParameterValues.Clear()
    #$Global:PSDefaultParameterValues.Add("*:Credential",$Cred)     # Uncomment to always have -Credential be populated with $Cred
    $Global:PSDefaultParameterValues.Add("Get-ChildItem:Force",$True)
    #$Global:PSDefaultParameterValues.Add("Receive-Job:Keep",$True)
    $Global:PSDefaultParameterValues.Add("Format-Table:AutoSize",{if ($host.Name -eq "ConsoleHost"){$true}})
    #$Global:PSDefaultParameterValues.Add("Send-MailMessage:To","<emailaddress>")
    #$Global:PSDefaultParameterValues.Add("Send-MailMessage:SMTPServer","mail.whatever.com")
    $Global:PSDefaultParameterValues.Add("Update-Help:Module","*")
    $Global:PSDefaultParameterValues.Add("Update-Help:ErrorAction","SilentlyContinue")
    $Global:PSDefaultParameterValues.Add("Test-Connection:Quiet",$True)
    $Global:PSDefaultParameterValues.Add("Test-Connection:Count","1")
    $Global:PSDefaultParameterValues.Add('Get-Help:ShowWindow',$true)
}
$Shutdown = {
    Restore-OMPOriginalPSDefaultParameter
}
$Unload = {
    Restore-OMPOriginalPSDefaultParameter
}