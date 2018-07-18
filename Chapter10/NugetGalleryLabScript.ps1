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

# After everything is installed, install the NuGet server
# and add SQL permissions
$vsJson = @'
{
  "installChannelUri": ".\\ChannelManifest.json",
  "channelUri": "https://aka.ms/vs/15/release/channel",
  "installCatalogUri": ".\\Catalog.json",
  "channelId": "VisualStudio.15.Release",
  "productId": "Microsoft.VisualStudio.Product.Enterprise",

  "installPath": "C:\\VS2017",
  "quiet": true,
  "passive": true,
  "includeRecommended": true,
  "norestart": false,

  "addProductLang": [
    "en-US"
    ],

    "add": [
        "Microsoft.VisualStudio.Workload.NativeDesktop",
        "Microsoft.VisualStudio.Workload.NetWeb"
    ]
}
'@
$jsonpath = [System.IO.Path]::ChangeExtension(([System.IO.Path]::GetTempFileName()), 'json')

$vsJson | Out-File $jsonpath -Force
Copy-LabFileItem -Path $jsonpath -ComputerName NUGSV01 -DestinationFolderPath C:

$vs = Get-LabInternetFile -Uri 'https://download.visualstudio.microsoft.com/download/pr/12390476/52257ee3e96d6e07313e41ad155b155a/vs_Enterprise.exe' -Path "$labsources\SoftwarePackages\vs_Enterprise.exe" -PassThru
$sdk = Get-LabInternetFile -Uri 'https://download.microsoft.com/download/A/1/D/A1D07600-6915-4CB8-A931-9A980EF47BB7/NDP47-DevPack-KB3186612-ENU.exe' -Path "$labsources\SoftwarePackages\NDP47-DevPack-KB3186612-ENU.exe" -PassThru -NoDisplay
$git = Get-LabInternetFile -Uri 'https://github.com/git-for-windows/git/releases/download/v2.17.1.windows.2/Git-2.17.1.2-64-bit.exe' -Path $Labsources\SoftwarePackages\git.exe -PassThru
Install-LabSoftwarePackage -Path $sdk.Path -CommandLine '/q' -ComputerName NUGSV01
Install-LabSoftwarePackage -Path $git.Path -CommandLine '/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"' -ComputerName NUGSV01
Install-LabSoftwarePackage -Path $vs.Path -CommandLine "--in C:\$(Split-Path -Leaf -Path $jsonpath)" -ComputerName NUGSV01

Invoke-LabCommand -ComputerName NUGSV01 -ScriptBlock {
git clone https://github.com/NuGet/NuGetGallery.git C:\NugetGallery 2>$null
& 'C:\NugetGallery\build.ps1' -Configuration release

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
} -ActivityName 'CloneAndBuild'
