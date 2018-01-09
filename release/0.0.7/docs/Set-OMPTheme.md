---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://github.com/zloeber/ohmypsh
schema: 2.0.0
---

# Set-OMPTheme

## SYNOPSIS
Sets the theme.

## SYNTAX

```
Set-OMPTheme [-NoProfileUpdate] [-Safe] [-Name <String>]
```

## DESCRIPTION
Sets the theme.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-OMPTheme -Name 'base'
```

## PARAMETERS

### -NoProfileUpdate
Skip updating the profile

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Safe
Will not save the theme in the profile if there are any errors.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The theme to load.
Will be applied immediately

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

[https://github.com/zloeber/ohmypsh](https://github.com/zloeber/ohmypsh)

