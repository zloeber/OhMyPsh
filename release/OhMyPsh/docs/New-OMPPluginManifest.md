---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# New-OMPPluginManifest

## SYNOPSIS
Creates a new OMP Plugin manifest file.

## SYNTAX

```
New-OMPPluginManifest [-Name] <String> [[-Path] <String>] [[-Version] <String>] [[-Description] <String>]
```

## DESCRIPTION
Creates a new OMP Plugin manifest file.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-OMPPluginManifest -Name 'mygreatplugin' -Version '0.0.1' -Description 'My great plugin'
```

Creates 'mygreatplugin' manifest file in the mygreatplugin directory of the current and displays the full path to the created plugin.

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
Path of the manifest file.
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

### -Version
Version of the plugin.
Defaults to 0.0.1.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: 0.0.1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Plugin description for the manifest file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
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

