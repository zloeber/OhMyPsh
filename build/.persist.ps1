Function New-BuildVariable {
    <#
        This function checks for the passed variable one scope level above the function. If it 
        already exists then it is left alone otherwise it is created with the passed values.
    #>
    Param (
        [Parameter(Position = 0)]
        [string]$Name,
        [Parameter(Position = 1)]
        $Value
    )
    if ((Get-Variable $Name -Scope 1 -ErrorAction:SilentlyContinue) -eq $null) {
        New-Variable -Name $Name -Value $Value -Scope 1 -Description "Build variable $Name"
    }
}

Function Get-TestHash {
    Param (
        [Parameter(Position = 0)]
        [string]$Name,
        [Parameter(Position = 1)]
        $Value
    )
    @{
        $Name = $Value
    }
}

Function Get-HashValueGUI {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [HashTable]$Hash
    )
    $FuncTemplate = @'
Function Get-BuildEnv {
    [CmdletBinding()]
    Param (
        {{Paramblock}}
    )
    $ReturnHash = @{}
    $ParameterList = (Get-Command -Name $MyInvocation.InvocationName).Parameters;
    foreach ($Parameter in $ParameterList) {
        Get-Variable -Name $Parameter.Values.Name -ErrorAction SilentlyContinue | Foreach {
            $ReturnHash.($_.Name) = $_.Value
        }
    }

    $ReturnHash
}
'@
$ParamBlock = ''
$i = 0
$ParamTemplate = "{{ParamType}}`${{ParamName}} = {{ParamValue}}"
    foreach ($Key in $Hash.Keys ) {
        $ParamName = $Key
        if (($Hash[$Key]).count -gt 1) {
            $ParamValue = (Convert-ArrayToString -Array $Hash[$Key] -Flatten)
            $ParamType = '[string[]]'
        }
        else {
            if ([string]::IsNullOrEmpty($Hash[$Key])) {
                $ParamValue = '""'
            }
            else {
                $ParamValue = '"' + $Hash[$Key] + '"'
            }
            $ParamType = '[string]'
        }
        $ParamBlock += $ParamTemplate -replace '{{ParamType}}',$ParamType -replace '{{ParamName}}',$ParamName -replace '{{ParamValue}}',$ParamValue
        if ($i -ne (($Hash.Keys).Count -1) -and (($Hash.Keys).Count -ne 1)) {
            $ParamBlock += ",`r`n        "
        }
        $i++
    }
    $MyFunc = $FuncTemplate -replace '{{Paramblock}}', $ParamBlock

    [scriptblock]::Create($MyFunc)
}