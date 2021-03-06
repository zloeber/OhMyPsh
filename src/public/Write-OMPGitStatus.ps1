function Write-OMPGitStatus {
    <#
    .SYNOPSIS
    Outputs to the screen a short output of the current directory git status.
    .DESCRIPTION
    Outputs to the screen a short output of the current directory git status.
    .LINK
    https://github.com/zloeber/OhMyPsh
    .EXAMPLE
    Write-OMPGitStatus
    .NOTES
    Author: Zachary Loeber
    #>

    switch ($Script:OMPProfile['OMPGitOutput']) {
        'posh-git' {
            Write-VcsStatus
        }
        'psgit' {
            Write-VcsStatus
        }
        Default {
            # Script or other method
            if (Test-OMPInAGitRepo) {
                $status = Get-OMPGitStatus
                $currentBranch = Get-OMPGitBranchName

                Write-Host '[' -nonewline -foregroundcolor Yellow
                Write-Host $currentBranch -nonewline

                $gitstatus = ' +' + $status["added"] + ' ~' + $status["modified"] + ' -' + $status["deleted"] + ' !' + $status["untracked"] + ']'
                Write-Host $gitstatus -foregroundcolor Yellow -NoNewline
            }
        }
    }
}
