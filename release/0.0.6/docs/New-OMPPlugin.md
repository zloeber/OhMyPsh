---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# New-OMPPlugin

## SYNOPSIS
Creates a new OMP Plugin template.

## SYNTAX

```
New-OMPPlugin [-Name] <String> [[-Path] <String>]
```

## DESCRIPTION
Creates a new OMP Plugin template.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-OMPPlugin -Name 'mygreatplugin'
```

Creates 'mygreatplugin' in the plugins directory and displays the full path to the created plugin.

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
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path of the plugin.
The default path is the plugin folder in the module directory.

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

