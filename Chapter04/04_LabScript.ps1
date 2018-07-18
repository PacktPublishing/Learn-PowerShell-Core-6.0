# Windows PowerShell Only at the moment
if (-not (Get-InstalledModule -Name AutomatedLab -ErrorAction SilentlyContinue))
{
    Install-Module AutomatedLab -Force
    $folder = New-LabSourcesFolder
    Write-Warning -Message "Only execute the script again once you downloaded a Windows Server 2016 image to $folder\ISOs"
    return
}

New-LabDefinition -Name TheShepherd -DefaultVirtualizationEngine HyperV

Add-LabDomainDefinition -Name contoso.com -AdminUser install -AdminPassword Somepass1
Set-LabInstallationCredential -Username install -Password Somepass1

Add-LabMachineDefinition -Name Shepherd -Memory 1GB -Roles RootDC -OperatingSystem 'Windows Server 2016 Datacenter' -DomainName contoso.com
1..32 | ForEach-Object {
    Add-LabMachineDefinition -Name ('NODE{0:d2}' -f $_) -Memory 512MB -OperatingSystem 'Windows Server 2016 Datacenter' -DomainName contoso.com
}

Install-Lab