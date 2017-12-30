---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Import-OMPModule

## SYNOPSIS
Attempt to load and optionally install a powershell module.

## SYNTAX

```
Import-OMPModule [-Name] <String[]> [[-Prefix] <String>]
```

## DESCRIPTION
Attempt to load and optionally install a powershell module.
By default all installed modules are scoped to the current user.

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

### -Prefix
Prefix commands imported.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

[https://www.github.com/zloeber/OhMyPsh](https://www.github.com/zloeber/OhMyPsh)

