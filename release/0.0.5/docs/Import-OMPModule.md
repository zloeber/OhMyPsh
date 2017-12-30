---
external help file: OhMyPsh-help.xml
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Import-OMPModule

## SYNOPSIS
Attempt to load and optionally install a powershell module.

## SYNTAX

```
Import-OMPModule [-Name] <String[]>
```

## DESCRIPTION
Attempt to load and optionally install a powershell module.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Import-OMPModule -Name 'posh-git'
```

If not already imported attempt to import posh-git. 
If the OhMyPsh profile allows, attempt to automatically install posh-git if it isn't found.

## PARAMETERS

### -Name
Name of the module

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber



Version History
1.0.0 - Initial release

## RELATED LINKS

