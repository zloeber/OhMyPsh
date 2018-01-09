Set-OMPConsoleColor -ErrorForegroundColor 'Red' `
    -WarningForegroundColor 'Yellow' `
    -DebugForegroundColor 'Green' `
    -VerboseForegroundColor 'Blue' `
    -ProgressForegroundColor 'Gray' `
    -ErrorBackgroundColor 'Black' `
    -WarningBackgroundColor 'Black' `
    -DebugBackgroundColor 'Black' `
    -VerboseBackgroundColor 'Black' `
    -ProgressBackgroundColor 'Cyan'

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