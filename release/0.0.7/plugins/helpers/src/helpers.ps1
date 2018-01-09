function Global:Reset-Module ($ModuleName) {
    Remove-Module $ModuleName
    Import-Module $ModuleName -force -pass | Format-Table Name, Version, Path -AutoSize
}

function Global:here {
    # Little helper function. Great for quick paths to the clipboard (ie. here | clip)
    (Get-Location).Path
}

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