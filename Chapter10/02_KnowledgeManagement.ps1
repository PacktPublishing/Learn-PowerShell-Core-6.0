#region Basics

# The PlatyPS module makes generating help a breeze
Install-Module PlatyPS -Force -Scope CurrentUser

# If you want, review the module code first
Get-Content .\VoiceCommands\VoiceCommands.psd1
Get-Content .\VoiceCommands\VoiceCommands.psm1

# For an existing module, generate help
# WithModulePage generates an additional landing page
Import-Module .\VoiceCommands
$param = @{
    Module         = 'VoiceCommands'
    WithModulePage = $true
    OutputFolder   = '.\MarkdownHelp'
}
New-MarkdownHelp @param

# The generated help content can be extended
psedit .\MarkdownHelp\Out-Voice.md

# After each commit to a specific branch
# or as a regular task, the help can be updated
# Existing documentation will be kept intact
Update-MarkdownHelp -Path .\MarkdownHelp

# As a build task, you might want to generate the
# MAML help
New-ExternalHelp -Path .\MarkdownHelp -OutputPath .\VoiceCommands\en-us

# Try it out
Remove-Module VoiceCommands
Import-Module .\VoiceCommands
Get-Help Out-Voice -Full
#endregion

#region Hosting help

# In order to create a little lab environment we use AutomatedLab
if (-not (Get-Module AutomatedLab -List))
{
    Install-Module AutomatedLab -Force -AllowClobber
}

# Create new lab definition
New-LabDefinition SimpleWebServer -DefaultVirtualizationEngine HyperV

# Add lab machines - make sure that Get-LabAvailableOperatingSystem returns something
Add-LabMachineDefinition -Name PACKTIIS -Roles WebServer -OperatingSystem 'Windows Server 2016 Datacenter'

Install-Lab

Invoke-LabCommand -ComputerName PACKTIIS -ActivityName ConfigureWebsite -ScriptBlock {
    Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath 'IIS:\Sites\Default Web Site' -Value $true -Force
    [void] (New-Item -ItemType Directory -Path C:\inetpub\wwwroot\helpfiles)
    New-SmbShare -Name helpshare -Path C:\inetpub\wwwroot\helpfiles -FullAccess "Everyone","Guests","Anonymous Logon"
}

# After generating the external help, you need to host it
# We need to change our FWLink first.
$moduleGuid = (Get-Module VoiceCommands).Guid.Guid
[void] (New-PSDrive -Name help -PSProvider FileSystem -Root \\PACKTIIS\helpshare -Credential (new-object pscredential('Administrator',('Somepass1' | ConvertTo-SecureString -AsPlain -Force))))
$helpshare = 'help:\'
$helpUri = 'http://PACKTIIS/helpfiles'

(Get-Content .\VoiceCommands\VoiceCommands.psd1 -Raw) -replace 'HelpInfoURI = .*',"HelpInfoUri = '$helpUri'" | Out-File .\VoiceCommands\VoiceCommands.psd1 -Force
(Get-Content .\MarkdownHelp\VoiceCommands.md -Raw) -replace '{{Please enter FwLink manually}}', $helpUri | Out-File .\MarkdownHelp\VoiceCommands.md -Force
(Get-Content .\MarkdownHelp\VoiceCommands.md -Raw) -replace '{{Please enter version .* format}}', '1.0.0.0' | Out-File .\MarkdownHelp\VoiceCommands.md -Force

$helpParam = @{
    CabFilesFolder  = '.\VoiceCommands\en-us'
    LandingPagePath = '.\MarkdownHelp\VoiceCommands.md'
    OutputFolder    = $helpshare
}
New-ExternalHelpCab @helpParam

# Update-Help will now download from your internal URL
# The verbose settings will show which URLs are being resolved and which files are used
Update-Help -Module VoiceCommands -Verbose

# Providing online help is also important
# Online links are provided on a cmdlet-basis
$link = 'http://lmgtfy.com/?s=d&q=Supporting+Online+Help'
(Get-Content .\MarkdownHelp\Out-Voice.md -Raw) -replace 'online version:.*',"online version: $link"
New-ExternalHelp -Path .\MarkdownHelp -OutputPath .\VoiceCommands\en-us -Force

Remove-Module VoiceCommands -ErrorAction SilentlyContinue
Import-Module .\VoiceCommands

Get-Help Out-Voice -Online # :-)
#endregion
