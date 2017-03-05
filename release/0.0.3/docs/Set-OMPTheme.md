---
external help file: OhMyPsh-help.xml
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Set-OMPTheme

## SYNOPSIS
Sets the theme.

## SYNTAX

```
Set-OMPTheme [[-Name] <String>] [-NoProfileUpdate]
```

## DESCRIPTION
Sets the theme.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-OMPTheme -Name 'base'
```

## PARAMETERS

### -Name
Name of the Theme

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: $Script:OMPProfile['Theme']
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

## RELATED LINKS

