Function Restore-OMPOriginalConsole {
    <#
    .SYNOPSIS
        Restores the original console colors and title.
    .DESCRIPTION
        Restores the original console colors and title.
    .EXAMPLE
        PS> Restore-OMPOriginalConsole

    .NOTES
        Author: Zachary Loeber


        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param ()
    Write-Output 'Restoring original console title'
    $Global:Host.UI.RawUI.WindowTitle = $Script:HostState['Title']

    Write-Output 'Restoring original console colors (this does not include psreadline configurations)'
    $Global:Host.UI.RawUI.ForegroundColor = $Script:HostState['Colors']['ForegroundColor']
    $Global:Host.UI.RawUI.BackgroundColor = $Script:HostState['Colors']['BackgroundColor']

    # Host Foreground
    $Global:Host.PrivateData.ErrorForegroundColor = $Script:HostState['Colors']['ErrorForegroundColor']
    $Global:Host.PrivateData.WarningForegroundColor = $Script:HostState['Colors']['WarningForegroundColor']
    $Global:Host.PrivateData.DebugForegroundColor = $Script:HostState['Colors']['DebugForegroundColor']
    $Global:Host.PrivateData.VerboseForegroundColor = $Script:HostState['Colors']['VerboseForegroundColor']
    $Global:Host.PrivateData.ProgressForegroundColor = $Script:HostState['Colors']['ProgressForegroundColor']

    # Host Background
    $Global:Host.PrivateData.ErrorBackgroundColor = $Script:HostState['Colors']['ErrorBackgroundColor']
    $Global:Host.PrivateData.WarningBackgroundColor = $Script:HostState['Colors']['WarningBackgroundColor']
    $Global:Host.PrivateData.DebugBackgroundColor = $Script:HostState['Colors']['DebugBackgroundColor']
    $Global:Host.PrivateData.VerboseBackgroundColor = $Script:HostState['Colors']['VerboseBackgroundColor']
    $Global:Host.PrivateData.ProgressBackgroundColor = $Script:HostState['Colors']['ProgressBackgroundColor']
}