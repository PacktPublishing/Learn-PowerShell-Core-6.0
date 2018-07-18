$SiteServer = "CM01"
$SiteCode = "P01"
 
# Get SMS_TaskSequencePackage WMI object
$TaskSequencePackage = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Filter "PackageID like 'P01000CB'"
$TaskSequencePackage.Get()
 
# Get SMS_TaskSequence WMI object from TaskSequencePackage
$TaskSequence = Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Name "GetSequence" -ArgumentList $TaskSequencePackage
 
# Convert WMI object to XML
$TaskSequenceResult = Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequence -ComputerName $SiteServer -Name "SaveToXml" -ArgumentList $TaskSequence.TaskSequence
$TaskSequenceXML = $TaskSequenceResult.ReturnValue
 
# Amend variable for Apply Operating System step with new PackageID
$ApplyOperatingSystemVariableNode = Select-Xml -Xml $TaskSequenceXML -XPath "//variable[contains(@name,'ImagePackageID')]"
$ApplyOperatingSystemVariableNode.Node.'#text' = $ApplyOperatingSystemVariableNode.Node.'#text' -replace "[A-Z0-9]{3}[A-F0-9]{5}", "P0100011"
 
# Amend command line for Apply Operating System step with new PackageID
$ApplyOperatingSystemCommandLineNode = Select-Xml -Xml $TaskSequenceXML -XPath "//step[contains(@name,'Apply Operating System')]"
$ApplyOperatingSystemCommandLineNode.Node.action = $ApplyOperatingSystemCommandLineNode.Node.action -replace "[A-Z0-9]{3}[A-F0-9]{5}", "P0100011"
 
# Convert XML back to SMS_TaskSequencePackage WMI object
$TaskSequenceResult = Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Name "ImportSequence" -ArgumentList $TaskSequenceXML.OuterXml
 
# Update SMS_TaskSequencePackage WMI object
Invoke-WmiMethod -Namespace "root\SMS\site_$($SiteCode)" -Class SMS_TaskSequencePackage -ComputerName $SiteServer -Name "SetSequence" -ArgumentList @($TaskSequenceResult.TaskSequence, $TaskSequencePackage)