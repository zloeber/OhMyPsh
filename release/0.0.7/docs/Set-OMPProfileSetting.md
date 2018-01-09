---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://github.com/zloeber/ohmypsh
schema: 2.0.0
---

# Set-OMPProfileSetting

## SYNOPSIS
Set one of the OMP settings.

## SYNTAX

```
Set-OMPProfileSetting [-Value] <Object> [-Name <String>]
```

## DESCRIPTION
Set one of the OMP settings.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-OMPSetting -Name 'SomeSetting' -Value 'somevalue'
```

## PARAMETERS

### -Value
Value of the setting

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The setting to update the value of.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

[https://github.com/zloeber/ohmypsh](https://github.com/zloeber/ohmypsh)

