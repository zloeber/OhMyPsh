
Function Optimize-OMPProfile {
 <#
    .SYNOPSIS
        Runs ngen on powershell assemblies. This can sometimes optimize startup times for PowerShell. 
    .DESCRIPTION
        Runs ngen on powershell assemblies. This can sometimes optimize startup times for PowerShell.
    .EXAMPLE
        PS> Optimize-OMPProfile

    .NOTES
        Author: Zachary Loeber


        Info: http://stackoverflow.com/questions/4208694/how-to-speed-up-startup-of-powershell-in-the-4-0-environment
        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
    Param()
    $env:path = (@($env:path -split ';') + [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() | Sort-Object -Unique) -join ';'
    [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
        if (-not $_.location) {
            continue
        }
        $Name = Split-Path $_.location -leaf
        Write-Output "NGENing : $Name"
        ngen install $_.location | ForEach-Object {"`t$_"}
    }
}