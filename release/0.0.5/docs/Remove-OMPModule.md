---
external help file: OhMyPsh-help.xml
online version: https://www.github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Remove-OMPModule

## SYNOPSIS
Removes a module from this session.

## SYNTAX

```
Remove-OMPModule [-Name] <String[]> [-PluginSafe]
```

## DESCRIPTION
Removes a module from this session.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Remove-OMPModule -Name 'posh-git' -PluginSafe
```

Removes posh-git from this session if it was not autoloaded or loaded when OhMyPsh started.

## PARAMETERS

### -Name
Name of the module

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PluginSafe
If you are removing the module as part of a plugin use this switch to only unload a module if it isn't
in the autoloaded modules OhMyPsh profile setting or loaded prior to OhMyPsh being started.
Note that
this is not 'safe' if there are multiple plugins loaded with the same module requirements.

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

