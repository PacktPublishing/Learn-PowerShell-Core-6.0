---
external help file: VoiceCommands-help.xml
Module Name: VoiceCommands
online version:
schema: 2.0.0
---

# Out-Voice

## SYNOPSIS
Outputs any given string to the default audio device

## SYNTAX

```
Out-Voice [-Text] <String> [[-Gender] <String>] [[-VoiceCulture] <CultureInfo>] [<CommonParameters>]
```

## DESCRIPTION
Outputs any string to the default audio device. The voice gender and culture can be selected. The cmdlet defaults to the installed voice if the selected voice is not insstalled.

## EXAMPLES

### Example 1
```powershell
PS C:\> 'Packt Publishing is awesome!' | Out-Voice -Gender Male -VoiceCulture de-DE
```

{{ Add example description here }}

## PARAMETERS

### -Gender
{{Fill Gender Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Male, Female

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text
{{Fill Text Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -VoiceCulture
{{Fill VoiceCulture Description}}

```yaml
Type: CultureInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
