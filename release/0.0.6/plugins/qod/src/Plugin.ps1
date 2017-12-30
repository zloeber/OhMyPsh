##  Superfluous but fun quotes. 
function Global:Get-Quote {
    param(
        $Path = (Get-OMPProfileSetting -Name 'QuoteDirectory'),
        [int]$Count=1
    )
    if(-not (Test-Path $Path) ) {
        $Path = Join-Path ${QuoteDir} $Path
        if(-not (Test-Path $Path) ) {
            $Path = $Path + ".txt"
        }
    }
    Get-Content $Path | Where-Object { $_ } | Get-Random -Count $Count
}