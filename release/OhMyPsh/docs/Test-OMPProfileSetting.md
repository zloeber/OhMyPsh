---
external help file: OhMyPsh-help.xml
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Test-OMPProfileSetting

## SYNOPSIS
Check if a profile setting exists.

## SYNTAX

```
Test-OMPProfileSetting [[-Name] <String>]
```

## DESCRIPTION
Check if a profile setting exists.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Test-OMPProfileSetting -Name 'SomeSetting'
```

If SomeSetting exists then $true is returned.
Otherwise $false is returned.

## PARAMETERS

### -Name
Name of the setting.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

