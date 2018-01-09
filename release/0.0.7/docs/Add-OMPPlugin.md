---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://github.com/zloeber/ohmypsh
schema: 2.0.0
---

# Add-OMPPlugin

## SYNOPSIS
Dot sources a plugin

## SYNTAX

```
Add-OMPPlugin [-Force] [-NoProfileUpdate] [-UpdateConfig] [-DebugOutput] [-Name <String>]
```

## DESCRIPTION
Dot sources a plugin and enables it for your profile.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Add-OMPPlugin -Name 'o365'
```

### -------------------------- EXAMPLE 2 --------------------------
```
'chocolatey','o365' | Add-OMPPlugin
```

## PARAMETERS

### -Force
If the plugin is already loaded use this to force load it again.

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

### -UpdateConfig
Force an update of the plugin configuration.
If a config scriptblock is passed then that will be used as the update.
Otherwise if a config scriptblock is found in the plugin that will be used instead.
This is an advanced parameter that should rarely need to be used.

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

### -DebugOutput
Show some additional output for debugging purposes.

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
The plugin to add to your profile and optionally load.

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

