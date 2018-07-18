#region NuGet setup
# Bootstrapping the PowerShellGet NuGet provider for offline systems
# nuget.exe is necessary to use Publish-Module and nuget pack

# Systemwide
$PSGetProgramDataPath = Join-Path -Path $env:ProgramData -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'

# CurrentUser
$PSGetAppLocalPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'

if (-not $PSGetProgramDataPath)
{
    [void] (New-Item -ItemType Directory -Path $PSGetProgramDataPath -Force)
}

if (-not $PSGetAppLocalPath)
{
    [void] (New-Item -ItemType Directory -Path $PSGetAppLocalPath -Force)
}

Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile (Join-Path $PSGetAppLocalPath nuget.exe)

# Bootstrapping the NuGet dll for the PackageManagement module
# Systemwide 
$assemblyPath = 'C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208'

# Current user
$assemblyPath = Join-Path $env:LOCALAPPDATA 'PackageManagement\ProviderAssemblies\nuget\2.8.5.208'


[void] (New-Item -ItemType Directory -Path $assemblyPath -Force)
Invoke-WebRequest https://oneget.org/Microsoft.PackageManagement.NuGetProvider-2.8.5.208.dll -OutFile "$assemblyPath\Microsoft.PackageManagement.NuGetProvider.dll" 
#endregion

#region Interacting with a repository

# Register internal repository
Register-PSRepository -Name Internal -SourceLocation https://NUGSV01/api/v2 -PublishLocation https://NUGSV01/api/v2/package

# Recreate PSGallery repository if it has been removed
Register-PSRepository -Default

# Discover any existing modules
Find-Module -Repository Internal

# Upload VoiceCommands module
# Data in PSD1 file will be used to generate metadata
$apiKey = 'oy2ihe7sqbggn4e7hcwq66ipg2btwduutimb3bbyxrfdm4'
Publish-Module -Name VoiceCommands -NuGetApiKey $apiKey -Repository Internal -Tags Voice, Automation

# Install module on another server, another user, ...
Install-Module -Name VoiceCommands -Repository Internal -Scope CurrentUser

# Done with a module?
Uninstall-Module -Name VoiceCommands

# JEA

# Find role capability by name
Find-RoleCapability -Name FirstLevelUserSupport

# Find modules with specific role capability
Find-Module -RoleCapability FirstLevelUserSupport

# Install modules with found psrc files to prepare for a JEA endpoint deployment
Find-Module -RoleCapability FirstLevelUserSupport |
    Install-Module

# Register endpoint with freshly downloaded, production JEA psrc files
$parameters = @{
    Path                = '.\JeaWithPowerShellGet.pssc'
    RunAsVirtualAccount = $true
    TranscriptDirectory = 'C:\Transcripts'
    SessionType         = 'RestrictedRemoteServer'
    LanguageMode        = 'ConstrainedLanguage'
    RoleDefinitions     = @{'contoso\FirstLevel' = @{RoleCapabilities = 'FirstLevelUserSupport'}}
}

# This would come from source control
New-PSSessionConfigurationFile @parameters

# This would be part of an automated rollout
Register-PSSessionConfiguration -Name SupportSession -Path .\JeaWithPowerShellGet.pssc

#endregion

#region Deploying

# Interactive
# AllowClobber allows installing modules that overwrite existing cmdlets
Install-Module AutomatedLab -Scope CurrentUser -RequiredVersion 5.3 -AllowClobber
Install-Script -Name Speedtest -Scope CurrentUser

# 1-m
Invoke-Command -ComputerName HostA, HostB, HostC -ScriptBlock {
    Install-Module -Name MyInfrastructureModule -Repository InternalGallery
}

# Explore the PowerShellGet module
psedit (Join-Path (Get-Module PowerShellGet -List)[-1].ModuleBase PSModule.psm1)

# Explore all installed modules
# using PowerShellGet
Get-InstalledModule

# PowerShellGet uses PackageManagement internally
Get-Package -ProviderName PowerShellGet

# In case you were wondering: There is more you can do with PackageManagement
Get-Package -ProviderName msi, Programs

# Removing modules is very easy
Get-InstalledModule -Name Format-Pester | Uninstall-Module

# And removing software is very easy as well!
Get-Package -Name Graphviz | Uninstall-Package

# Updating modules

# The catch-all solution
Get-InstalledModule | Update-Module

# Updating individual modules
Get-InstalledModule AutomatedLab, datum | Update-Module

# Automating updates
#region Scheduled Windows and Linux
# ScheduledJobs are also working, if you need the additional output
$parameters = @{
    TaskName = 'PowerShellModuleUpdate'
    TaskPath = '\KRAFTMUSCHEL'
    Trigger  = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    Action   = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -Command "{Get-InstalledModule | Update-Module}"'
    Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -RunOnlyIfNetworkAvailable
}
Register-ScheduledTask @parameters

# Scheduled Tasks: Linux style
# REVIEW CODE before just downloading from URLs
[System.Net.WebClient]::new().DownloadFile('https://raw.githubusercontent.com/PowerShell/PowerShell/master/demos/crontab/CronTab/CronTab.psm1', 'CronTab.psm1')

# Perfect access to cron via PowerShell :)
Import-Module .\CronTab.psm1

New-CronJob -Minute 0 -Hour 5 -Command "pwsh -Command '&{Get-InstalledMOdule | Update-Module}'"
Get-CronTab
#endregion

#region Profile - platform-independent

# The profile could also be used to update modules. Be careful however
# as this process might take a substantial amount of time!
Add-Content -Path $profile -Value 'Get-InstalledModule | Update-Module' -Force

# To be more flexible in your session you can register a job and have the job
# inform you when it is done.
$job = Start-Job { Get-InstalledModule | Update-Module -Force }

$null = Register-ObjectEvent $job -EventName StateChanged -SourceIdentifier JobEnd -Action {

    if($sender.State -eq 'Completed')
    {
        $duration = $job.PSEndTime - $job.PSBeginTime
        Write-Host "Module update finished in $duration. Results available in `$global:jobInfo"
        $global:jobInfo = Receive-Job $job
        $job | Remove-Job
    } 
}   

#endregion


#region Updating JEA servers
$modulePath = Join-Path -Path ($env:PSModulePath -split ';')[1] -ChildPath JeaRoles
$manifestPath = Join-Path $modulePath -ChildPath 'JeaRoles.psd1'
$roleCapabilitiesPath = Join-Path $modulePath -ChildPath RoleCapabilities

if (-not (Test-Path $roleCapabilitiesPath))
{
    [void] (New-Item -ItemType Directory -Path $roleCapabilitiesPath -Force)
}

$parameters = @{
    Path = (Join-Path $roleCapabilitiesPath ModuleServicing.psrc)
    ModulesToImport = @(
        'PackageManagement'
        'PowerShellGet'
    )
}

New-PSRoleCapabilityFile @parameters

$parameters = @{
    Path = $manifestPath
    ModuleVersion = '1.0.0'
    FileList = @(
        'RoleCapabilities\JeaServicing.psrc'
    )
}
New-ModuleManifest @parameters

$parameters = @{
    SessionType = 'RestrictedRemoteServer'
    Path = '.\Servicing.pssc'
    TranscriptDirectory = 'C:\Transcripts'
    RunAsVirtualAccount = $true
    RoleDefinitions = @{
        'contoso\OrchestratorServicing' = @{ 
            RoleCapabilities = 'ModuleServicing'
        }
    }
    LanguageMode = 'ConstrainedLanguage'
}
New-PSSessionConfigurationFile @parameters

$parameters = @{
    Path = '.\Servicing.pssc'
    Force = $true
    Name = 'JeaServicing'
}
Register-PSSessionConfiguration @parameters

# Test the new endpoint
Enter-PSSession -ComputerName $env:COMPUTERNAME -ConfigurationName JeaServicing
Get-Command # Displays the PackageManagement and PowerShellGet cmdlets now

# Typical lifecycle
Install-Module AutomatedLab.Common,Datum -Force -AllowClobber

Get-InstalledModule | Update-Module -Force

Uninstall-Module Datum

#endregion

#endregion