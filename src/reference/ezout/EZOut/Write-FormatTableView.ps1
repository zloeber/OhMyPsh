function Write-FormatTableView
{
    param(
    # The list of properties to export.
    [Parameter(ParameterSetName='PropertyTable',
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
    [String[]]$Property,

    # If set, will rename the properties in the table.
    # The oldname is the name of the old property, and value is either the new header
    [Parameter(ParameterSetName='PropertyTable', ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [string]) {
                throw "All keys and values in the property rename map must be strings" 
            }
        }
        return $true
    })]
    [Hashtable]$RenamedProperty,
    
    # If set, will create a number of virtual properties within a table
    [Parameter(ParameterSetName='PropertyTable', ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        foreach ($kv in $_.GetEnumerator()) {
            if ($kv.Key -isnot [string] -or $kv.Value -isnot [ScriptBlock]) {
                throw "The virtual property may only contain property names and the script blocks that will produce the property" 
            }
        }
        return $true    
    })]
    [Hashtable]$VirtualProperty,
    # If set, the table will be autosized.
    [Parameter(ParameterSetName='PropertyTable',
        ValueFromPipelineByPropertyName=$true)]
    [Switch]
    $AutoSize,
    
    # The width of any the properties.  This parameter is optional, and cannot be used with
    # AutoSize
    # A negative width is a right justified table.
    # A positive width is a left justified table
    # A width of 0 will be ignored.
    [ValidateRange(-80,80)]
    [Parameter(ParameterSetName='PropertyTable',
        ValueFromPipelineByPropertyName=$true)]
    [Int[]]$Width, 
             
     # If wrap is set, then items in the table can span multiple lines
    [Parameter(ParameterSetName='PropertyTable')]
    [Switch]$Wrap       
    )

    process {
            $header =@"
<TableControl>
    $(if ($autosize) { "<AutoSize />" } )
"@
            $tableHeader = "
<TableHeaders>
"
            $tableContent = ""
            $tableContentHeader = "
<TableRowEntries>
    <TableRowEntry>
        $(if ($Wrap) { "<Wrap/>" }) 
    <TableColumnItems>
"
    
            $tableContentFooter = "
    </TableColumnItems>
    </TableRowEntry>
</TableRowEntries>
            "
            $footer = @"
</TableControl>
"@
            for ($i =0; $i -lt $property.Count; $i++) {
                $p = $property[$i]
                # If there was a custom width defined, use it                                
                
                if ($Width -and $Width[$i]) {
                    if ($Width[$i] -lt 0) {
                        $widthTag = "
                        <Width>$([Math]::Abs($Width[$i]))</Width>
                        <Alignment>right</Alignment>
                        "                        
                    } else {
                        $widthTag = "
                        <Width>$([Math]::Abs($Width[$i]))</Width>
                        <Alignment>left</Alignment>
                        "                        
                    }                    
                } else {
                    $widthTag = ""
                }
                
                if ($FormatProperty.$p) {
                    $format = "<FormatString>$($FormatProperty.$p)</FormatString>"
                } else {
                    $format = ""
                }
                
                $label = ""
                # If there was an alias defined for this property, use it
                if ($RenamedProperty.$p -or $VirtualProperty.$p) {
                    $label = "<Label>$p</Label>"
                    if ($RenamedProperty.$p) {
                                
                        $tableContent += "<TableColumnItem><PropertyName>$($RenamedProperty.$p)</PropertyName>$Format</TableColumnItem>"
                    } else {
                        $tableContent += "<TableColumnItem><ScriptBlock>$($VirtualProperty.$p)</ScriptBlock></TableColumnItem>"
                    }
                } else {
                    $tableContent += "<TableColumnItem><PropertyName>$p</PropertyName>$Format</TableColumnItem>"
                }
                $TableHeader += "<TableColumnHeader>${Label}${WidthTag}</TableColumnHeader>"                                
            }
            $tableHeader += "</TableHeaders>"
            $header + $TableHeader + $tableContentHeader + $tableContent + $tableContentFooter + $footer        
    }
}