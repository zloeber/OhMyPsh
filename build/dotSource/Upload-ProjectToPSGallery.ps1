#Requires -version 5
function Script:Upload-ProjectToPSGallery {
    <#
        .SYNOPSIS
            Upload module project to Powershell Gallery
        .DESCRIPTION
            Upload module project to Powershell Gallery
        .PARAMETER ModulePath
            Path to module to upload.
        .PARAMETER APIKey
            API key for the powershellgallery.com site.
        .EXAMPLE
            .\Upload-ProjectToPSGallery.ps1
        .NOTES
        Author: Zachary Loeber
        Site: http://www.the-little-things.net/


        Version History
        1.0.0 - Initial release
        #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, HelpMessage='Path of module project files to upload.')]
        [string]$Path,
        [parameter(HelpMessage='Destination gallery (default is PSGallery)')]
        [string]$Repository = 'PSGallery',
        [parameter(HelpMessage='API key for the powershellgallery.com site.')]
        [string]$NuGetApiKey
    )

    $MyParams = $PSCmdlet.MyInvocation.BoundParameters
    $MyParams.Keys | ForEach {
        Write-Verbose "Adding manually defined parameter $($_)"
        $PublishParams.$_ = $MyParams[$_]
    }

    # if no API key is defined then look for psgalleryapi.txt in the local profile directory and try to use it instead.
    if ([string]::IsNullOrEmpty($PublishParams.NuGetApiKey)) {
        $psgalleryapipath = "$(Split-Path $Profile)\psgalleryapi.txt"
        Write-Verbose "No PSGallery API key specified. Attempting to load one from the following location: $($psgalleryapipath)"
        if (-not (test-path $psgalleryapipath)) {
            Write-Error "$psgalleryapipath wasn't found and there was no defined API key, please rerun script with a defined APIKey parameter."
            return
        }
        else {
            $PublishParams.NuGetApiKey = get-content -raw $psgalleryapipath
        }
    }

    # If we made it this far then try to publish the module wth our loaded parameters
    Publish-Module @PublishParams
}