function Get-OMPIPAddress {
    <#
    .SYNOPSIS
    Platform independant retrieval of the current primary IP address.
    .DESCRIPTION
    Platform independant retrieval of the current primary IP address.
    .LINK
    https://github.com/zloeber/OhMyPsh
    .EXAMPLE
    Get-OMPIPAddress
    .NOTES
    Author: Zachary Loeber
    #>
    [CmdletBinding()]
    param(
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    process {
    }
    end {
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
        Write-Verbose "$($FunctionName): End."
    }
}
