---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Set-OMPGitOutput

## SYNOPSIS
Sets the default git output module.
This can be used to flip between posh-git and psgit modules.

## SYNTAX

```
Set-OMPGitOutput [[-Name] <String>]
```

## DESCRIPTION
Sets the default git output module.
This can be used to flip between posh-git and psgit modules.
This is important for customized prompt output as well as in general for managing git repos on your system.
The default is just to use some basic scripts with this module.
otherwise this can be posh-git or psgit (named so after the modules that get loaded).
Write-OMPGitStatus uses this setting directly to determine how to spit out VCS information to the prompt.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-OMPGitOutput -Name 'psgit'
```

## PARAMETERS

### -Name
Name of the git output module to use.
psgit, posh-git, or script.
Default is script and no modules are used for writing version control to the prompt.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: Script
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

[https://github.com/zloeber/OhMyPsh](https://github.com/zloeber/OhMyPsh)

