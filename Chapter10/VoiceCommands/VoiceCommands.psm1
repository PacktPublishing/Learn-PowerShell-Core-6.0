function Out-Voice
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]
        $Text,

        [ValidateSet('Male', 'Female')]
        [System.String]
        $Gender = 'Female',

        [cultureinfo]
        $VoiceCulture = 'en-us'
    )

    begin
    {
        $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $synth.SelectVoiceByHints($Gender, 30, $null, $VoiceCulture)
        $synth.SetOutputToDefaultAudioDevice()
    }

    process
    {  
        $synth.Speak($Text)
    }

    end
    {
        $synth.Dispose()
    }
}

New-Alias -Name ov -Value Out-Voice -Description "Alias for voice cmdlet Out-Voice" -Force

# SIG # Begin signature block
# MIIFdgYJKoZIhvcNAQcCoIIFZzCCBWMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUA64Y0dQQZL+uBZ9oWNGLdPK+
# L16gggMOMIIDCjCCAfKgAwIBAgIQPrrJV+yDMZVA3AQ9PR+9bDANBgkqhkiG9w0B
# AQUFADAdMRswGQYDVQQDDBJDb2RlU2lnbmluZ0lzR3JlYXQwHhcNMTgwNjAxMDkz
# ODE1WhcNMTkwNjAxMDk1ODE1WjAdMRswGQYDVQQDDBJDb2RlU2lnbmluZ0lzR3Jl
# YXQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDkwm6taUjZdP0hDwSf
# oGhX00hCJpnMj5x0iWjlBxA7uOrW0a+nzMJtr3Nh9OPYCbd0CCUSG57bDej3YAKx
# PbikzcsM0/5gPHREbihV3FbyrXgU3S4lLahH9T4YybHeZO5fHywVkD6FoyhltHAM
# ysYK4aXQD2RdBEdZOtsLsmAY4muQk12erKFM+yPK24sPLuT5CoxmSZ/JSo/UX3A/
# nd8S9nPMO3RNCZSPgcGkCMVf2exrElYUELdE/rfR+4+FPxyaKU/S7RzcsYJ0qTAL
# V2UXjD7ZTH4p2k3Yblp1tQQPbGNJxEMXyUrilMS3re6UFf5Fyl1RlExPjuI8/h2w
# c3FtAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHQ4EFgQUkmX7NYTdNqCE/bawJ9jiH3K+7MowDQYJKoZIhvcNAQEFBQAD
# ggEBABkrEVDkz3i0D2ajGW3R1pgzT3dMjUfc0Vv6bc+6v39tW9/K4GLvZc8wdX/s
# DrQnPFRG4tAcAyih/8YwqwYGGvS/88wBv30ADVCADs6E5ZGXWkgTVi+vOb6JIgEu
# ioPGKoaAWzsTIZGgppdqXqg2L3eGHjCuzjOkTYjr95zhPiRMBypMn61MQfNbkd+Z
# kwoNZDjthUxAOr1b+Ja5Fw2qT6E8dEhcYEQ9Gk5fFnP77Wpa86WPPJ1LRHlXXBrN
# 9RcO99jcgtdJq8ggSkQ7/HpHzhbkeQ1YEsbLflqkYCuLZ2CFP5Q2PKoky2c0eJYq
# s+5Cwp2Y9aq4qChAI9ZOFSnG3rgxggHSMIIBzgIBATAxMB0xGzAZBgNVBAMMEkNv
# ZGVTaWduaW5nSXNHcmVhdAIQPrrJV+yDMZVA3AQ9PR+9bDAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUn1dUeqwE6ZXforHU1r1DRmx+GnAwDQYJKoZIhvcNAQEBBQAEggEADq5ncVqA
# KzJ7TvizgS9ygKIs60G9fYA17/initCm2tQw24/wQT6E7ObL0KSkh1Ie8o+ZZ8yz
# YcDuFVftfqpvOisRn5RRGkz+oQ0xfitUJhH7xhi754y71bTxHWQorqwFReEz9Am3
# 4PgNOZ3XpZfeXIjvEwJstuyDM95qzwFcI+MsHuoi854aVGmQWTlh1QHIXGkolcGK
# tumD0SemXmMIKueieeZBbnwFsiv70yS+O7rYc2r/o6yIaWKSdAsnVzF8ZfWFtdKT
# o+YXIWDH32YZuAXuavU5vBcGOKXoa7R4l6e7+ZqZn2YTGjsZ3B6VeniK7vdibosS
# fNGUkm24saGDgw==
# SIG # End signature block
