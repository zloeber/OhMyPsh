---
external help file: OhMyPsh-help.xml
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Import-OMPProfile

## SYNOPSIS
Loads a user profile.

## SYNTAX

```
Import-OMPProfile [[-Path] <String>]
```

## DESCRIPTION
Loads a user profile.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Import-OMPProfile -Path C:\temp\.OhMyPsh.profile.json
```

Loads the profile from C:\temp\.OhMyPsh.profile.json into the module settings

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

