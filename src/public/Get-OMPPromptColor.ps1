Function Get-OMPPromptColor {
    <#
    .SYNOPSIS
    Display the Prompt color settings.
    .DESCRIPTION
    Display the Prompt color settings.
    .EXAMPLE
    PS> Get-OMPPromptColor

    Shows the Prompt color settings
    .NOTES
    Author: Zachary Loeber
    .LINK
    https://www.github.com/zloeber/OhMyPsh
    #>
    [CmdletBinding()]
	param ()

    [psobject]@{
        BackgroundColor = $Host.UI.RawUI.BackgroundColor
        ForegroundColor = $Host.UI.RawUI.ForegroundColor
        ErrorForegroundColor = $Host.PrivateData.ErrorForegroundColor
        WarningForegroundColor = $Host.PrivateData.WarningForegroundColor
        DebugForegroundColor = $Host.PrivateData.DebugForegroundColor
        VerboseForegroundColor = $Host.PrivateData.VerboseForegroundColor
        ProgressForegroundColor = $Host.PrivateData.ProgressForegroundColor
        ErrorBackgroundColor = $Host.PrivateData.ErrorBackgroundColor
        WarningBackgroundColor  = $Host.PrivateData.WarningBackgroundColor
        DebugBackgroundColor = $Host.PrivateData.DebugBackgroundColor
        VerboseBackgroundColor = $Host.PrivateData.VerboseBackgroundColor
        ProgressBackgroundColor = $Host.PrivateData.ProgressBackgroundColor
    }
}