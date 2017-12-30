Function Set-OMPPSColor {
    <#
    .SYNOPSIS
        Sets the PSColor settings.
    .DESCRIPTION
        Sets the PSColor settings.
    .PARAMETER Setting
        Hash containging the PSColor settings.
    .EXAMPLE
        PS> Set-OMPPSColor -Setting  @{
            File = @{
                Default    = @{ Color = 'White' }
                Directory  = @{ Color = 'Green'}
                Reparse    = @{ Color = 'Magenta'}
                Hidden     = @{ Color = 'DarkGray'; Pattern = '^\.' }
                Code       = @{ Color = 'Magenta'; Pattern = '\.(java|c|cpp|cs|js|css|html|Dockerfile|gradle|pp|packergitignore|gitattributes|go|)$' }
                Executable = @{ Color = 'Green'; Pattern = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg|sh|fsx|)$' }
                Text       = @{ Color = 'Cyan'; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown|properties|json|todo)$' }
                Compressed = @{ Color = 'Yellow'; Pattern = '\.(zip|tar|gz|rar|jar|war)$' }
            }
            Service = @{
                Default = @{ Color = 'White' }
                Running = @{ Color = 'DarkGreen' }
                Stopped = @{ Color = 'DarkRed' }
            }
            Match = @{
                Default    = @{ Color = 'White' }
                Path       = @{ Color = 'Green'}
                LineNumber = @{ Color = 'Yellow' }
                Line       = @{ Color = 'White' }
            }
        }

        Set the PSColor settings to the hash
    .NOTES
        Author: Zachary Loeber



        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true)]
        [hashtable]$Setting
    )
    $Script:PSColor = $Setting.Clone()
}