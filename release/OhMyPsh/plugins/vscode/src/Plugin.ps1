<#
#A quick template function
function Global:Some-Function {
    [CmdletBinding( )]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name
    )

    Begin {
        $Names = @()
    }

    Process {
        $Names += $Name
    }

    End {
        $Names | ForEach-Object {
            $_
        }
    }
}
#>

<# Or an alias perhaps
Set-Alias -Name mycmd -Value cmd -option AllScope -Scope Global
#>