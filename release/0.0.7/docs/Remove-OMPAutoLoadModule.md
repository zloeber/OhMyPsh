---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Remove-OMPAutoLoadModule

## SYNOPSIS
Removes a module to be autoloaded when OMP starts up.

## SYNTAX

```
Remove-OMPAutoLoadModule [-Name] <String> [-NoProfileUpdate]
```

## DESCRIPTION
Removes a module to be autoloaded when OMP starts up.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Remove-OMPAutoLoadModule -Name 'posh-git'
```

Removes posh-git from the list of modules that will be loaded when OhMyPsh starts.

## PARAMETERS

### -Name
Name of the module

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

[https://www.github.com/zloeber/OhMyPsh](https://www.github.com/zloeber/OhMyPsh)

