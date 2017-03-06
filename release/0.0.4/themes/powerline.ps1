<#
    Another one of Joel Bennett's works.
    This is an example of an advanced theme with some additional plugin requirements
    You can either install and set the modules to autoload with OhMyPsh OR just
    enable the powerline and psgit plugins which will automatically download, install,
    and load the appropriate modules as well.
        Add-OMPPlugin psgit
        Add-OMPPlugin powerline
#>
if ((-not (get-module psgit)) -or (-not (Get-Module Powerline))) {
    Write-Output "Cannot use this theme without the powerline and psgit plugins (or modules) loaded!"
    Write-Output "You can add these with the following commands:"
    Write-Output '    Add-OMPPlugin psgit'
    Write-Output '    Add-OMPPlugin powerline'
    return
}

$Global:PowerLinePrompt = 1,
    (
        $null, # No left-aligned content on this line
        @(
            @{ text = { New-PowerLineBlock (Get-Elapsed) -ErrorBackgroundColor DarkRed -ErrorForegroundColor White -ForegroundColor Black -BackgroundColor DarkGray } }
            @{ bg = "Gray";     fg = "Black"; text = { Get-Date -f "T" } }
        )
    ),  @(
            @{ bg = "Blue";     fg = "White"; text = { $MyInvocation.HistoryId } }
            @{ bg = "Cyan";     fg = "White"; text = { [PowerLine.Prompt]::Gear * $NestedPromptLevel } }
            @{ bg = "Cyan";     fg = "White"; text = { if($pushd = (Get-Location -Stack).count) { "$([char]187)" + $pushd } } }
            @{ bg = "DarkBlue"; fg = "White"; text = { $pwd.Drive.Name } }
            @{ bg = "DarkBlue"; fg = "White"; text = { Split-Path $pwd -leaf } }
            # PSGit is still in early stages, but it has PowerLine support
            @{ text = { Get-GitStatusPowerline } }
        )

Set-PowerLinePrompt -CurrentDirectory -PowerlineFont:(!$SafeCharacters) -Title { "PowerShell - {0} ({1})" -f (Convert-Path $pwd),  $pwd.Provider.Name }

# Setting a (slightly modified) Dark Solarized color theme as well
# Host Foreground
$Host.PrivateData.ErrorForegroundColor = 'Red'
$Host.PrivateData.WarningForegroundColor = 'Yellow'
$Host.PrivateData.DebugForegroundColor = 'Green'
$Host.PrivateData.VerboseForegroundColor = 'Blue'
$Host.PrivateData.ProgressForegroundColor = 'Gray'

# Host Background
$Host.PrivateData.ErrorBackgroundColor = 'Black'
$Host.PrivateData.WarningBackgroundColor = 'Black'
$Host.PrivateData.DebugBackgroundColor = 'Black'
$Host.PrivateData.VerboseBackgroundColor = 'Black'
$Host.PrivateData.ProgressBackgroundColor = 'Cyan'

# Check for PSReadline
if (Get-Module -ListAvailable -Name "PSReadline") {
    $options = Get-PSReadlineOption

    # Foreground
    $options.CommandForegroundColor = 'Yellow'
    $options.ContinuationPromptForegroundColor = 'DarkBlue'
    $options.DefaultTokenForegroundColor = 'DarkBlue'
    $options.EmphasisForegroundColor = 'Cyan'
    $options.ErrorForegroundColor = 'Red'
    $options.KeywordForegroundColor = 'Green'
    $options.MemberForegroundColor = 'DarkCyan'
    $options.NumberForegroundColor = 'DarkCyan'
    $options.OperatorForegroundColor = 'DarkGreen'
    $options.ParameterForegroundColor = 'DarkGreen'
    $options.StringForegroundColor = 'Blue'
    $options.TypeForegroundColor = 'DarkYellow'
    $options.VariableForegroundColor = 'Green'

    # Background
    $options.CommandBackgroundColor = 'Black'
    $options.ContinuationPromptBackgroundColor = 'Black'
    $options.DefaultTokenBackgroundColor = 'Black'
    $options.EmphasisBackgroundColor = 'Black'
    $options.ErrorBackgroundColor = 'Black'
    $options.KeywordBackgroundColor = 'Black'
    $options.MemberBackgroundColor = 'Black'
    $options.NumberBackgroundColor = 'Black'
    $options.OperatorBackgroundColor = 'Black'
    $options.ParameterBackgroundColor = 'Black'
    $options.StringBackgroundColor = 'Black'
    $options.TypeBackgroundColor = 'Black'
    $options.VariableBackgroundColor = 'Black'
}