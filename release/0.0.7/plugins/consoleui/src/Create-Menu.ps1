function Global:CreateMenu ($Title, $MenuItems, $TitleColor, $LineColor, $MenuItemColor) {
    #CreateMenu -Title "THIS IS TITLE" -MenuItems "Exchange Server","Active Directory","Sytem Center Configuration Manager","Lync Server","Microsoft Azure" -TitleColor Red -LineColor Cyan -MenuItemColor Yellow
    [string]$Title = "$Title"
    $TitleCount = $Title.Length
    $LongestMenuItem = ($MenuItems | Measure-Object -Maximum -Property Length).Maximum
    if ($TitleCount -lt $LongestMenuItem) {
        $reference = $LongestMenuItem
    }
    else
    {$reference = $TitleCount}
    $reference = $reference + 10
    $Line = "═" * $reference
    $TotalLineCount = $Line.Length
    $RemaniningCountForTitleLine = $reference - $TitleCount
    $RemaniningCountForTitleLineForEach = $RemaniningCountForTitleLine / 2
    $RemaniningCountForTitleLineForEach = [math]::Round($RemaniningCountForTitleLineForEach)
    $LineForTitleLine = "`0" * $RemaniningCountForTitleLineForEach
    $Tab = "`t"
    Write-Host "╔" -NoNewline -f $LineColor; Write-Host $Line -NoNewline -f $LineColor; Write-Host "╗" -f $LineColor
    if ($RemaniningCountForTitleLine % 2 -eq 1) {
        $RemaniningCountForTitleLineForEach = $RemaniningCountForTitleLineForEach - 1
        $LineForTitleLine2 = "`0" * $RemaniningCountForTitleLineForEach
        Write-Host "║" -f $LineColor -nonewline; Write-Host $LineForTitleLine -nonewline -f $LineColor; Write-Host $Title -f $TitleColor -nonewline; Write-Host $LineForTitleLine2 -f $LineColor -nonewline; Write-Host "║" -f $LineColor
    }
    else {
        Write-Host "║" -nonewline -f $LineColor; Write-Host $LineForTitleLine -nonewline -f $LineColor; Write-Host $Title -f $TitleColor -nonewline; Write-Host $LineForTitleLine -nonewline -f $LineColor; Write-Host "║" -f $LineColor
    }
    Write-Host "╠" -NoNewline -f $LineColor; Write-Host $Line -NoNewline -f $LineColor; Write-Host "╣" -f $LineColor
    $i = 1
    foreach ($menuItem in $MenuItems) {
        $number = $i++
        $RemainingCountForItemLine = $TotalLineCount - $menuItem.Length - 9
        $LineForItems = "`0" * $RemainingCountForItemLine
        Write-Host "║" -nonewline -f $LineColor ; Write-Host $Tab -nonewline; Write-Host $number"." -nonewline -f $MenuItemColor; Write-Host $menuItem -nonewline -f $MenuItemColor; Write-Host $LineForItems -nonewline -f $LineColor; Write-Host "║" -f $LineColor
    }
    Write-Host "╚" -NoNewline -f $LineColor; Write-Host $Line -NoNewline -f $LineColor; Write-Host "╝" -f $LineColor
}