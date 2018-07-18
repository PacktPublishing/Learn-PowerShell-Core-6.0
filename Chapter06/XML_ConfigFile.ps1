
#XMLConfigFile
$XMLContent = @'
<?xml version="1.0" standalone="yes"?>
<Config>	
	<TargetCollectionDefault>Windows10_1</TargetCollectionDefault>
	<TargetCollection>
		<Collection company_id = "A">Windows10_1_A</Collection>
		<Collection company_id = "B">Windows10_12</Collection>
		<Collection company_id = "C">Windows10_1_B</Collection>
    </TargetCollection>
    <ADLocations>
        <Mandant Name="School" Nummer="1" UserName="Guest" OrgName="School" OSDVersion="Win7" Domain="sl1.contoso.net" DomainDC="DC=sl1,DC=contoso,DC=net"></Mandant>		
        <Mandant Name="School" Nummer="3" UserName="Guest" OrgName="School" OSDVersion="Win10" Domain="sl2.contoso.net" DomainDC="DC=sl2,DC=contoso,DC=net"></Mandant>		
        <Mandant Name="University" Nummer="45" UserName="Student" OrgName="N1" OSDVersion="Win7" Domain="un1.contoso.net" DomainDC="DC=un1,DC=contoso,DC=net"></Mandant>		
        <Mandant Name="University" Nummer="67" UserName="Student" OrgName="N1" OSDVersion="Win10" Domain="un2.contoso.net" DomainDC="DC=un2,DC=contoso,DC=net"></Mandant>		
    </ADLocations>
	<PCType>
		<Type Name = "Desktop PC" Value='D'></Type>
		<Type Name = "Notebook" Value='N'></Type>
		<Type Name = "Tablet PC" Value='T'></Type>
	</PCType>
	<!-- Logfile configuration, If this section is uncomented logfile is written in the same folder as the script file.-->
	<Logdir>E:\Logs\</Logdir>
	<Logfile>SCCMLogs.txt</Logfile>
</Config>
'@

#Path where the config file is being saved
$configPath = 'c:\temp\config.xml'

#Saving config file
$XMLContent | Set-Content $configPath

#Loading xml as config
[XML] $configXml = Get-Content -Path $configPath -ErrorAction 'Stop'

#region some examples for loading and filtering data
$configXml.Config.TargetCollectionDefault
$configXml.Config.TargetCollection.Collection
$configXml.Config.ADLocations.Mandant | Where-Object {$_.Name -eq 'School'} | Out-GridView

$NewGUIDforNotebook = ($configXml.Config.PCType.Type | Where-Object {$_.Name -like 'Notebook'}).Value + [guid]::NewGuid()

if ($configXml.Config.Logdir -ne $null)
{
	$LogDir = $configXml.Config.Logdir
	$LogFile = $configXml.Config.LogFile
}

$LogDir
$LogFile
#endregion