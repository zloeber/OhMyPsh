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



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param ()
    
    $Script:PromptColors
}