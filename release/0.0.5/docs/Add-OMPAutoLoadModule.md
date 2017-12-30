---
external help file: OhMyPsh-help.xml
online version: 
schema: 2.0.0
---

# Add-OMPAutoLoadModule

## SYNOPSIS
Adds a module to be autoloaded when OMP starts up.

## SYNTAX

```
Add-OMPAutoLoadModule [-Name] <String> [-NoProfileUpdate]
```

## DESCRIPTION
Adds a module to be autoloaded when OMP starts up.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Add-OMPAutoLoadModule -Name 'posh-git'
```

Adds posh-git to the list of modules that will be loaded with OhMyPsh for this user.

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



Version History
1.0.0 - Initial release

## RELATED LINKS

