function Set-OMPConsoleColor {
    <#
    .SYNOPSIS
    Sets different console colors.
    .DESCRIPTION
    Sets different console colors. PSReadline will almost always overwrite this if it is loaded.
    .PARAMETER BackgroundColor
    Console background color
    .PARAMETER ForegroundColor
    Console foreground color
    .PARAMETER ErrorForegroundColor
    Console Error foreground color
    .PARAMETER WarningForegroundColor
    Console Warning foreground color
    .PARAMETER DebugForegroundColor
    Console Debug foreground color
    .PARAMETER VerboseForegroundColor
    Console Verbose foreground color
    .PARAMETER ProgressForegroundColor
    Console Progress background color
    .PARAMETER ErrorBackgroundColor
    Console Error background color
    .PARAMETER WarningBackgroundColor
    Console Warning background color
    .PARAMETER DebugBackgroundColor
    Console Debug background color
    .PARAMETER VerboseBackgroundColor
    Console Verbose background color
    .PARAMETER ProgressBackgroundColor
    Console Progress background color
    .LINK
    https://github.com/zloeber/OhMyPsh
    .EXAMPLE
    TBD
    .NOTES
    Author: Zachary Loeber
    #>

    [CmdletBinding()]
    param(
        $BackgroundColor,
        $ForegroundColor,
        $ErrorForegroundColor,
        $WarningForegroundColor,
        $DebugForegroundColor,
        $VerboseForegroundColor,
        $ProgressForegroundColor,
        $ErrorBackgroundColor,
        $WarningBackgroundColor,
        $DebugBackgroundColor,
        $VerboseBackgroundColor,
        $ProgressBackgroundColor
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
        $PsreadlineIsLoaded = if (get-module psreadline) {$true} else {$false}
    }
    process {
        if ($PsreadlineIsLoaded) {
            Write-Verbose "$($FunctionName): Psreadline is loaded, setting psreadline options."
            $PSReadlineOptions = Get-PSReadlineOption
        }
        else {
            Write-Verbose "$($FunctionName): Psreadline is not loaded, setting default host console colors."
        }
        if ($null -ne $BackgroundColor) {
            Write-Verbose "$($FunctionName): Setting the BackgroundColor"
            if ($PsreadlineIsLoaded) {
                $PSReadlineOptions.CommandBackgroundColor = $BackgroundColor
            }
            $Host.UI.RawUI.BackgroundColor = [System.ConsoleColor]$BackgroundColor
        }
        if ($null -ne $ForegroundColor) {
            Write-Verbose "$($FunctionName): Setting the ForegroundColor"
            if ($PsreadlineIsLoaded) {
                $PSReadlineOptions.CommandForegroundColor = $ForegroundColor
            }
            $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]$ForegroundColor
        }
        if (($host.PrivateData | get-member -Type:Property).Count -gt 0) {
            if ($null -ne $ErrorForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the ErrorForegroundColor"
                if ($PsreadlineIsLoaded) {
                    $PSReadlineOptions.ErrorForegroundColor = $ErrorForegroundColor
                }
                $Host.PrivateData.ErrorForegroundColor = [System.ConsoleColor]$ErrorForegroundColor
            }
            if ($null -ne $WarningForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the WarningforegroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.WarningForegroundColor = $WarningForegroundColor
                #}
                $Host.PrivateData.WarningForegroundColor = [System.ConsoleColor]$WarningForegroundColor
            }
            if ($null -ne $DebugForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the DebugForegroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.DebugForegroundColor = $DebugForegroundColor
                #}
                $Host.PrivateData.DebugForegroundColor = [System.ConsoleColor]$DebugForegroundColor
            }
            if ($null -ne $VerboseForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the VerboseForegroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.VerboseForegroundColor = $VerboseForegroundColor
                #}
                $Host.PrivateData.VerboseForegroundColor = [System.ConsoleColor]$VerboseForegroundColor
            }
            if ($null -ne $ProgressForegroundColor) {
                Write-Verbose "$($FunctionName): Setting the ProgressForegroundColor"
               # if ($PsreadlineIsLoaded) {
               #     $PSReadlineOptions.ProgressForegroundColor = $ProgressForegroundColor
               # }
                $Host.PrivateData.ProgressForegroundColor = [System.ConsoleColor]$ProgressForegroundColor
            }
            if ($null -ne $ErrorBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the ErrorBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.ErrorBackgroundColor = $ErrorBackgroundColor
                #}
                $Host.PrivateData.ErrorBackgroundColor = [System.ConsoleColor]$ErrorBackgroundColor
            }
            if ($null -ne $WarningBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the WarningBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.WarningBackgroundColor = $WarningBackgroundColor
                #}
                $Host.PrivateData.WarningBackgroundColor = [System.ConsoleColor]$WarningBackgroundColor
            }
            if ($null -ne $DebugBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the DebugBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.DebugBackgroundColor = $DebugBackgroundColor
                #}
                $Host.PrivateData.DebugBackgroundColor = [System.ConsoleColor]$DebugBackgroundColor
            }
            if ($null -ne $VerboseBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the VerboseBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.VerboseBackgroundColor = $VerboseBackgroundColor
                #}
                $Host.PrivateData.VerboseBackgroundColor = [System.ConsoleColor]$VerboseBackgroundColor
            }
            if ($null -ne $ProgressBackgroundColor) {
                Write-Verbose "$($FunctionName): Setting the ProgressBackgroundColor"
                #if ($PsreadlineIsLoaded) {
                #    $PSReadlineOptions.ProgressBackgroundColor = $ProgressBackgroundColor
                #}
                $Host.PrivateData.ProgressBackgroundColor = [System.ConsoleColor]$ProgressBackgroundColor
            }
        }
    }
    end {
        Write-Verbose "$($FunctionName): End."
    }
}
