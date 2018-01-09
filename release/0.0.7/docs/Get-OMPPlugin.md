---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Get-OMPPlugin

## SYNOPSIS
Shows plugins and their load state.

## SYNTAX

```
Get-OMPPlugin [[-Name] <String>]
```

## DESCRIPTION
Shows plugins and their load state.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-OMPPlugin
```

Shows all OhMyPsh plugins and if they are loaded or not.

### -------------------------- EXAMPLE 2 --------------------------
```
Get-OMPPlugin qod | select *
```

Shows all the plugin properties of the qod plugin.

## PARAMETERS

### -Name
The plugin name.
If nothing is passed all plugins are listed.

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

### OMP.PluginStatus

## NOTES
Author: Zachary Loeber

## RELATED LINKS

[https://www.github.com/zloeber/OhMyPsh](https://www.github.com/zloeber/OhMyPsh)

