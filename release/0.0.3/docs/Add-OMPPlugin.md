---
external help file: OhMyPsh-help.xml
online version: 
schema: 2.0.0
---

# Add-OMPPlugin

## SYNOPSIS
Dot sources a plugin

## SYNTAX

```
Add-OMPPlugin [-Name] <String> [-Force] [-NoProfileUpdate] [-UpdateConfig]
```

## DESCRIPTION
Dot sources a plugin

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Add-OMPPlugin -Name 'o365'
```

## PARAMETERS

### -Name
Name of the plugin

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force
If the plugin is already loaded use this to force load it again.

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

### -UpdateConfig
Force an update of the plugin configuration.
If a config scriptblock is passed then that will be used as the update.
Otherwise if a config scriptblock is found in the plugin that will be used instead.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

