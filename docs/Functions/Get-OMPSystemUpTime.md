---
external help file: OhMyPsh-help.xml
Module Name: OhMyPsh
online version: https://github.com/zloeber/OhMyPsh
schema: 2.0.0
---

# Get-OMPSystemUpTime

## SYNOPSIS
Retreive platform independant uptime informaton (should run on both linux and windows properly).

## SYNTAX

```
Get-OMPSystemUpTime [-FromSleep]
```

## DESCRIPTION
Retreive platform independant uptime informaton (should run on both linux and windows properly).

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-OMPSystemUpTime
```

## PARAMETERS

### -FromSleep
For windows you can retrieve the time that the system has been up since it last was in sleep mode.
Uses event log entries to determine and can be time consuming.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

[https://github.com/zloeber/OhMyPsh](https://github.com/zloeber/OhMyPsh)

