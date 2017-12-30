<#
    Setup OhMyPsh then use the o365 plugin to get all shared mailboxes or disabled
    accounts that still have some form of o365 licensing assigned.

    Note: Ensure you accept the prompt to connect to MSOL.
#>

set-executionpolicy RemoteSigned
install-module ohmypsh
import-module ohmypsh
add-ompplugin o365

Connect-ExchangeOnline

 (Get-Mailbox).Where{($_.RecipientTypeDetails -ne 'Usermailbox') -or $_.AccountDisabled}.Foreach{Get-MsolUser -UserPrincipalName $_.UserPrincipalName}.Where{$_.IsLicensed}