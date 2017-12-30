Function Invoke-OMPPersonalFunction {
    <#
    .SYNOPSIS
        Dot sources a personal function file in the global context and tags it to ohmypsh.
    .DESCRIPTION
        Dot sources a personal function file in the global context and tags it to ohmypsh.
    .PARAMETER Path
        Path for the file to import.
    .PARAMETER Tag
        Tag to place on the function (in the form of a noteproperty).
    .EXAMPLE
        TBD
    .NOTES
        Author: Zachary Loeber


        Version History
        1.0.0 - Initial release
    #>
    [CmdletBinding()]
	param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Path,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$Tag
    )

    Begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        Write-Verbose "Attempting to load the file $Path"
    }

    Process {
        if (Test-Path $Path) {
            $errmsg = $null

            # Load the script, replace any root level functions with its global equivalent. Then invoke.
            $script = (Get-Content $Path -Raw) -replace '^function\s+((?!global[:]|local[:]|script[:]|private[:])[\w-]+)', 'function Global:$1'
            try {
                $sb = [Scriptblock]::create(".{$script}")
                Invoke-Command -NoNewScope -ScriptBlock $sb -ErrorVariable errmsg 2>$null
                if (-not ([string]::IsNullOrEmpty($errmsg))) {
                    throw "Unable to load script file $Path"
                }
            }
            catch {
                throw "Unable to load script file $Path"
            }

            # Next look for any globally defined functions and tag them with a noteproperty to track
            ([System.Management.Automation.Language.Parser]::ParseInput($script, [ref]$null, [ref]$null)).FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | Foreach-Object {
                if (($_.Name).StartsWith('Global:')) {
                    $globalfunc = Get-ChildItem -Path "Function:\$($_.Name -replace 'Global:','')" -ErrorAction:SilentlyContinue
                    if ($GlobalFunc -ne $null) {
                        Write-Verbose "Function exported into the global session: $($_.Name -replace 'Global:','')"
                        try {
                            $globalfunc | Add-Member -MemberType 'NoteProperty' -Name 'ohmypsh' -Value $Tag -Force
                        }
                        catch {
                            # Do nothing as the member probably already existed.
                        }
                    }
                }
            }
        }
        else {
            throw "Invalid Path: $Path"
        }
    }
}