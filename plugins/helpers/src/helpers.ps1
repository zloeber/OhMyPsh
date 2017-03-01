function Global:Reset-Module ($ModuleName) {
    Remove-Module $ModuleName
    Import-Module $ModuleName -force -pass | Format-Table Name, Version, Path -AutoSize
}

function Global:here {
    # Little helper function. Great for quick paths to the clipboard (ie. here | clip)
    (Get-Location).Path
}

function Global:Test-IsAdmin {
    if ( ([System.Environment]::OSVersion.Version.Major -gt 5) -and
          ( new-object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $true
    }
    else {
        $false
    }
}

function Global:Get-ChildItem-Wide {
    <#
         joonro/Get-ChildItem-Color
        https://github.com/joonro/Get-ChildItem-Color
        Add from https://github.com/JRJurman/PowerLS/blob/master/powerls.psm1
    #>
    $width =  $host.UI.RawUI.WindowSize.Width
    $pad = 2

    # get the longest string and get the length
    $childs = Get-ChildItem $Args
    $lnStr = $childs | select-object Name | sort-object { "$_".length } -descending | select-object -first 1
    $len = $lnStr.name.length

    $childs |
    ForEach-Object {
        $output = $_.name + (" "*($len - $_.name.length+$pad))
        $count += $output.length

        Write-Host $output -nonewline

        if ( $count -ge ($width - ($len+$pad)) ) {
          Write-Host ""
          $count = 0
      }
  }
}
Set-Alias -Name ls -Value Get-ChildItem-Wide -option AllScope -Scope Global

function Global:Split-HereString {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$String
    )
    Begin {
        $TheString = ''
    }
    Process {
        $TheString += $String
    }
    End {
        $TheString -Split  "\s*[\r\n]+\s*"
    }
}