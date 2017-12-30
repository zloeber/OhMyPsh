---
external help file: OhMyPsh-help.xml
online version: 
schema: 2.0.0
---

# Add-OMPProfileSetting

## SYNOPSIS
Adds a new setting to the user profile settings if they do not already exist.
Afterwards the profile is automatically exported and saved.

## SYNTAX

```
Add-OMPProfileSetting [-Name] <String> [[-Value] <Object>] [-NoProfileUpdate]
```

## DESCRIPTION
Adds a new setting to the user profile settings if they do not already exist.
Afterwards the profile is automatically exported and saved.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Add-OMPProfileSetting -Name 'CustomSetting' -Value 'MySetting'
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

### -Value
Value of the setting.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
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
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

