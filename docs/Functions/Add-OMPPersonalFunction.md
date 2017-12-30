---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://github.com/zloeber/ohmypsh
schema: 2.0.0
---

# Add-OMPPersonalFunction

## SYNOPSIS
Adds a function to be autoloaded into your session when OMP starts up.

## SYNTAX

```
Add-OMPPersonalFunction [-Path] <String> [-Recurse] [-NoProfileUpdate]
```

## DESCRIPTION
Adds a function to be autoloaded into your session when OMP starts up.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Add-OMPPersonalFunction -Path 'C:\users\jdoe\scripts\myscript.ps1'
```

Adds 'C:\users\jdoe\scripts\myscript.ps1' to the list of functions that will be loaded
with OhMyPsh for this user.

## PARAMETERS

### -Path
Name of the script.

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

### -Recurse
Add every script in the directory.

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
Skip updating the profile.

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

[https://github.com/zloeber/ohmypsh](https://github.com/zloeber/ohmypsh)

