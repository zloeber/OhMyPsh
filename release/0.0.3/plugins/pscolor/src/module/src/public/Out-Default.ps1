function Out-Default {
    <#
    .SYNOPSIS
    Proxy Out-Default command required for colorization of console output.
    .DESCRIPTION
    Proxy Out-Default command required for colorization of console output.
    .PARAMETER Transcript
    TBD
    .PARAMETER InputObject
    TBD
    #>
    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113362', RemotingCapability='None')]
    param(
        [switch]
        ${Transcript},

        [Parameter(Position=0, ValueFromPipeline=$true)]
        [psobject]
        ${InputObject})

    begin
    {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Core\Out-Default', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process {
        try {
            # Our snazzy hook for colorizing the output...
            if ($_ -ne $null) {
                if  ($Script:PSColorTypeMapKeys -contains ($_.pstypenames)[0]) {
                    .([scriptblock]::create($Script:PSColorTypeMap[$_.pstypenames[0]]))
                    $_ = $null
                }
                else {
                    $steppablePipeline.Process($_)
                }
            }
            else {
                $steppablePipeline.Process($_)
            }
        } catch {
            throw
        }
    }

    end {
        try {
            write-host ""
            $script:showHeader=$true
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }
}