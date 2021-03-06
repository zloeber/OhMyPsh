function Get-OMPGitStatus {
    <#
    .SYNOPSIS
    Returns the git branch based on the current directory.
    .DESCRIPTION
    Returns the git branch based on the current directory.
    .LINK
    https://github.com/zloeber/OhMyPsh
    .EXAMPLE
    Get-OMPGitStatus
    .NOTES
    Author: Zachary Loeber
    #>
    $deleted = 0
    $modified = 0
    $added = 0
    $untracked = 0

    try {
        $gitstatus = git status --porcelain --short
        $deleted = ($gitstatus | select-string '^D\s').count
        $modified = ($gitstatus | select-string '^M\s').count
        $added = ($gitstatus | select-string '^A\s').count
        $untracked = ($gitstatus | select-string '^\?\?\s').count
    }
    catch {}

    return @{
        "untracked" = $untracked
        "added" = $added
        "modified" = $modified
        "deleted" = $deleted
    }
}
