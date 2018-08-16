#region Setup

#region Create a suitable lab environment
$labName = 'NugetLab'

New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV

Add-LabDomainDefinition -Name contoso.com -AdminUser Install -AdminPassword Somepass1
Set-LabInstallationCredential -User Install -Password Somepass1

Add-LabVirtualNetworkDefinition -Name $labname -AddressSpace 192.168.22.0/24
Add-LabVirtualNetworkDefinition -Name External -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet' }

Add-LabIsoImageDefinition -Name SQLServer2017 -Path $labsources\ISOs\en_sql_server_2017_enterprise_x64_dvd_11293666.iso

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:DomainName' = 'contoso.com'
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 Datacenter (Desktop Experience)'
    'Add-LabMachineDefinition:Memory' = 2GB
    'Add-LabMachineDefinition:DnsServer1' = '192.168.22.10'
    'Add-LabMachineDefinition:Gateway'= '192.168.22.99'
    'Add-LabMachineDefinition:Network' = $labName
}

# Domain Controller and CA
Add-LabMachineDefinition -Name NUGDC01 -Roles RootDC -IpAddress 192.168.22.10

$netAdapter = @()
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $labName -Ipv4Address 192.168.22.99
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch External -UseDhcp
Add-LabMachineDefinition -Name NUGCA01 -Roles CARoot,Routing -NetworkAdapter $netAdapter

# Database and Web Server
Add-LabMachineDefinition -Name NUGDB01 -Roles SQLServer2017 -IpAddress 192.168.22.11
Add-LabMachineDefinition -Name NUGSV01 -Roles WebServer -IpAddress 192.168.22.12

Install-Lab
Enable-LabCertificateAutoenrollment -Computer -User

Checkpoint-LabVm -All -SnapshotName LabDeployed
#endregion

<# Assumptions
- Visual Studio is installed with at least the workload ASP.NET
- git must exist in $PATH for the build script to work
- A SQL server exists and we can connect to it
#>

# All steps are executed from the IIS host. Building the solution
# can be done on a development client instead if installing
# VisualStudio is not an option for the web server

# Gather sources
git clone https://github.com/NuGet/NuGetGallery.git C:\NugetGallery 2>$null

# Build the necessary libraries
& 'C:\NugetGallery\build.ps1' -Configuration release

# Modify web.config and copy files
Copy-Item -Path C:\NugetGallery\src\NugetGallery\* -Destination C:\NugetWebApp -Force -Recurse
$webConfig = [xml](Get-Content C:\NugetWebApp\web.config)
$dbNode = $webConfig.SelectSingleNode('/configuration/connectionStrings/add[@name="Gallery.SqlServer"]')
$dbNode.connectionString = 'Server=NUGDB01;Database=NuGetGallery;Trusted_Connection=true'
$dbNode = $webConfig.SelectSingleNode('/configuration/connectionStrings/add[@name="Gallery.SupportRequestSqlServer"]')
$dbNode.connectionString = 'Server=NUGDB01;Database=SupportRequest;Trusted_Connection=true'
$dbNode = $webConfig.SelectSingleNode('/configuration/connectionStrings/add[@name="Gallery.ValidationSqlServer"]')
$dbNode.connectionString = 'Server=NUGDB01;Database=Validation;Trusted_Connection=true'
$webServer = $webConfig.SelectSingleNode('/configuration/system.webServer')
$rewrite = $webConfig.SelectSingleNode('/configuration/system.webServer/rewrite')
[void] ($webServer.RemoveChild($rewrite))
$webConfig.Save('C:\NugetWebApp\web.config')

# Create the database and set database permissions
$batches = @(
    'USE [master]
CREATE LOGIN [CONTOSO\NUGSV01$] FROM WINDOWS'
    'USE [master]
CREATE DATABASE [NuGetGallery]
CREATE DATABASE [SupportRequest]
CREATE DATABASE [Validation]'
    'USE [NuGetGallery]
CREATE USER [nuget-site] FOR LOGIN [CONTOSO\NUGSV01$]'
    'USE [NuGetGallery]
EXEC sp_addrolemember "db_owner", "nuget-site"'
    'USE [SupportRequest]
CREATE USER [nuget-site] FOR LOGIN [CONTOSO\NUGSV01$]'
    'USE [SupportRequest]
EXEC sp_addrolemember "db_owner", "nuget-site"'
    'USE [Validation]
CREATE USER [nuget-site] FOR LOGIN [CONTOSO\NUGSV01$]'
    'USE [Validation]
EXEC sp_addrolemember "db_owner", "nuget-site"'
)

$sqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = 'Server=NUGDB01;Trusted_Connection=true'
$sqlConnection.Open()
foreach ($batch in $batches)
{
    $sqlCommand = new-Object -TypeName System.Data.SqlClient.SqlCommand
    $sqlCommand.CommandText = $batch
    $sqlCommand.CommandType = [System.Data.CommandType]::Text
    $sqlCommand.Connection = $sqlConnection
    [void] ($sqlCommand.ExecuteNonQuery())
}
$sqlConnection.Close()

# Run migrations for Entity Framework
& 'C:\NugetGallery\tools\Update-Databases.ps1' -MigrationTargets NugetGallery,NugetGallerySupportRequest,NugetGalleryValidation -NugetGallerySitePath C:\NugetWebApp

# Create app pool and web site
Get-WebSite -Name 'Default Web Site' | Remove-Website

New-WebAppPool -Name 'NuGetPool'
New-WebSite -Name NuGetGallery -Port 80 -PhysicalPath C:\NugetWebApp

# Profit

#endregion

#region Signatures
# Signing your modules
$codeSigningCert = Get-ChildItem Cert:\CurrentUser\my -CodeSigningCert
$param = @{
    FilePath = @(
        '.\Chapter10\VoiceCommands\VoiceCommands.psd1'
        '.\Chapter10\VoiceCommands\VoiceCommands.psm1'
    )
}
$setParam = $param.Clone()
$setParam.IncludeChain = 'all'
$setParam.Certificate = $codeSigningCert
Set-AuthenticodeSignature @setParam

# Check your signatures later on
Get-AuthenticodeSignature @param
#endregion

#region PowerShellGet

# Compare PackageManagement and PowerShellGet
Get-Command -Module PackageManagement
Get-Command -Module PowerShellGet

# List the pre-installed source
Get-PSRepository

# Connect to the source to download data
# For the default repository you don't need to specify the name
Find-Module AutomatedLab -Repository PSGallery

# Interacting with the repositories will prompt you to download
# nuget.exe, as it is the package provider to save and install modules
# Save a module to review the code
Save-Module AutomatedLab -Path .

# Install the module
Install-Module AutomatedLab -Scope CurrentUser

# Register our own repository
Register-PSRepository -Name Internal -SourceLocation https://NUGSV01/api/v2 -PublishLocation https://NUGSV01/api/v2


#endregion