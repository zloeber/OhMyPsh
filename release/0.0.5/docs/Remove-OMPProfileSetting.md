---
external help file: OhMyPsh-help.xml
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Remove-OMPProfileSetting

## SYNOPSIS
Removes a custom profile setting that is not one of the core settings.
Afterwards the profile is automatically exported and saved.

## SYNTAX

```
Remove-OMPProfileSetting [-Name] <String> [-NoProfileUpdate]
```

## DESCRIPTION
Removes a custom profile setting that is not one of the core settings.
Afterwards the profile is automatically exported and saved.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Remove-OMPProfileSetting -Name 'CustomSetting'
```

## PARAMETERS

### -Name
Name of the setting

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoProfileUpdate
Skip updating the profile

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber


Version History
1.0.0 - Initial release

## RELATED LINKS

