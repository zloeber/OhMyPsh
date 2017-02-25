param(
    [string]$ModuleName,
    [string]$ModuleWebsite,
    [string]$ModuleAuthor,
    [string]$ModuleDescription,
    [string]$ModuleTags,
    [string]$GithubRepo
)

# Required helper function
. .\build\dotsource\Convert-ArrayToString.ps1

$ModuleTagString = Convert-ArrayToString ($ModuleTags -split ',' | Foreach-Object {$_.Trim() -replace ' ','_' }) -Flatten

task UpdateBuildEnvironmentDefinitions {
    Write-Host -NoNewLine "      Updating the module definition file"
    try {
        (Get-Content -Raw '.\build\.buildenvironment.ps1') `
            -replace '{{ModuleName}}', $ModuleName `
            -replace '{{ModuleWebsite}}', $ModuleWebsite `
            -replace '{{ModuleAuthor}}', $ModuleAuthor `
            -replace '{{ModuleDescription}}', $ModuleDescription `
            -replace '{{ModuleTags}}', $ModuleTagString `
        | Out-File ".\build\$ModuleName.buildenvironment.ps1" -Force -Encoding:utf8
        Remove-Item -Path '.\build\.buildenvironment.ps1' -Force
        Write-Host -ForegroundColor Green '...Done!'
    }
    catch {
        throw 'Unable to update the build environment definition file'
    }
}

task PersistBuildEnvironmentDefinitions -After UpdateBuildEnvironmentDefinitions {
    Write-Host -NoNewLine "      Persisting the module definitions via an export file"
    . ".\build\$ModuleName.buildenvironment.ps1" -ForcePersist
    Write-Host -ForegroundColor Green '...Done!'
}

task CreateModuleFramework {
    Write-Host -NoNewLine "      Updating template files for the module framework"
    $null = Copy-Item .\build\templates\version.txt .\
    $null = Copy-Item .\build\templates\ModuleName.psm1 ".\$($ModuleName).psm1"

    (Get-Content -Raw .\build\templates\.build.ps1) -replace '{{BuildFile}}',".\build\$($ModuleName).buildenvironment.ps1" |
    Out-File ".\$($ModuleName).build.ps1" -Force -Encoding:utf8

    (Get-Content -Raw .\build\templates\Build.ps1) -replace '{{BuildFile}}',".\$($ModuleName).build.ps1" |
    Out-File '.\Build.ps1' -Force -Encoding:utf8
    Write-Host -ForegroundColor Green '...Done!'
}

task CreateInstallScript {
    Write-Host -NoNewLine "      Creating install script for the project"
    (Get-Content -Raw .\build\templates\Install.ps1) `
        -replace '{{ModuleName}}', $ModuleName `
        -replace '{{ModuleWebsite}}', $ModuleWebsite | 
        Out-File ".\Install.ps1" -Force -Encoding:utf8
    Write-Host -ForegroundColor Green '...Done!' 
}

task CreateModuleManifest {
    Write-Host -NoNewLine "      Creating an initial module manifest for the project"
    # Module Manifest Definition
    $ManifestDef = @{
        Path = ".\$($ModuleName).psd1"
        Guid = ([guid]::NewGuid()).Guid.ToString()
        Author = $ModuleAuthor
        CompanyName = $ModuleAuthor
        RootModule = "$ModuleName.psm1"
        ModuleVersion = '0.0.1'
        Description = $ModuleDescription
        PowerShellVersion = 3.0.0
        Tags = @($ModuleTags -split ',' | Foreach-Object {$_.Trim() -replace ' ','_' })
        ReleaseNotes = 'First Release'
        Copyright = "(c) $((get-date).Year.ToString()) $ModuleAuthor. All rights reserved."
        ProjectUri = $ModuleWebsite
        LicenseUri = "$ModuleWebsite/master/LICENSE.md"
        IconUri = "$ModuleWebsite/raw/master/src/other/powershell-project.png"
        FunctionsToExport = '*'
        CmdletsToExport = '*'
        AliasesToExport = '*'
        VariablesToExport = '*'
    }
    New-ModuleManifest @ManifestDef
    Write-Host -ForegroundColor Green '...Done!' 
}

task CreateModuleAboutHelp {
    Write-Host -NoNewLine '      Creating base about help txt file and directory'
    $null = New-Item -Type:Directory -Name 'en-US' -Path .\ -Force
    (Get-Content -Raw .\build\templates\about_ModuleName.help.txt) `
        -replace '{{ModuleName}}',$ModuleName `
        -replace '{{ModuleDescription}}', $ModuleDescription `
        -replace '{{Tags}}',($ModuleTagString -join ',') `
        -replace '{{HelpLink}}',$ModuleWebsite | Out-File ".\en-US\about_$($ModuleName).help.txt" -Force -Encoding:utf8
    Write-Host -ForegroundColor Green '...Done!' 
}

task CreateReadme {
    Write-Host -NoNewLine '      Creating initial readme.md'
    (Get-Content -Raw .\build\templates\readme.md) `
        -replace '{{ModuleName}}', $ModuleName `
        -replace '{{ModuleDescription}}', $ModuleDescription `
        -replace '{{ModuleAuthor}}', $ModuleAuthor `
        -replace '{{ModuleWebsite}}', $ModuleWebsite | Out-File ".\readme.md" -Encoding:utf8
    Write-Host -ForegroundColor Green '...Done!' 
}

task CreateGitRepo {
    # Validate git.exe requirement is met
    try {
        $null = Get-Command -Name 'git.exe' -ErrorAction:Stop
    }
    catch {
        throw 'Git.exe not found in path!'
    }

    exec { git init }
    exec { git add . }
    exec { git commit -m 'First Commit' }
}

task UploadToGithub -if (-not [string]::IsNullOrEmpty($GithubRepo)) {
    exec { git remote add origin $GithubRepo }
    exec { git remote -v }
    exec { git push origin master }
}

task RemoveGitRepo {
    if (((Get-ChildItem -Directory -Path "`.\.git").Count -gt 0) -or ((Get-ChildItem -Hidden -Directory -Path "`.\.git").Count -gt 0) ) {
        Write-Output '************************************'
        Write-Output '* Removing current .git directory! *'
        Write-Output '************************************'
        Write-Output ''
        Write-Output 'This is normally exactly what you want to do when Initializing a new module.'
        Write-Output 'Press any key to proceed (otherwise cancel with CTRL+C)...'
        pause
        Remove-Item -Path "`.\.git" -Recurse -Force
    }
}

task . UpdateBuildEnvironmentDefinitions, RemoveGitRepo, CreateModuleFramework, CreateInstallScript, CreateReadme, CreateModuleManifest, CreateModuleAboutHelp, CreateGitRepo, UploadToGithub