---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://github.com/zloeber/ohmypsh
schema: 2.0.0
---

# Export-OMPProfile

## SYNOPSIS
Saves a user profile.

## SYNTAX

```
Export-OMPProfile [[-Path] <String>]
```

## DESCRIPTION
Saves a user profile.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Export-OMPProfile -Path C:\temp\.OhMyPsh.profile.json
```

Saves the profile settings to C:\temp\.OhMyPsh.profile.json into the module settings

## PARAMETERS

### -Path
Path to the user module profile settings.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: $Script:OMPProfileExportFile
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

[https://github.com/zloeber/ohmypsh](https://github.com/zloeber/ohmypsh)

