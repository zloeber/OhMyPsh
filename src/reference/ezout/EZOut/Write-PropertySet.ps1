function Write-PropertySet
{
    <#
    .Synopsis
        Writes a property set
    .Description
        Writes a property set.



        Property sets are a way to conveniently access sets of properties on an object.  
        
        
        
        Instead of writing:
        
        
            Select-Object a,b,c,d


        You can write:



            Select-Object mypropertyset
    .Example
        Write-PropertySet -typename System.IO.FileInfo -name filetimes -propertyname Name, LastAccessTime, CreationTime, LastWriteTime | 
            Out-TypeData |
            Add-TypeData

        dir | select filetimes
    .Link
        ConvertTo-PropertySet
    .Link
        Get-PropertySet
    #>
    param(
    # The typename for the property set
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]
    $TypeName,


    # The name of the property set
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]
    $Name,

    # The names of the properties to include in the property set
    [string[]]
    $PropertyName
    )

    process {
        Write-TypeView -TypeName $TypeName -PropertySet @{$Name = $PropertyName } 
    }
} 
