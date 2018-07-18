
#region working with simple XPatch

#Path for Type formattings
$Path = "$Pshome\Types.ps1xml"

#Show
psedit "$Pshome\Types.ps1xml"

#XPath filter for returning Node objects and its ReferencedMemberName
$XPath = "/Types/Type/Members/AliasProperty"

#Retrieving the the data
Select-Xml -Path $Path -XPath $Xpath | Select-Object -ExpandProperty Node

#XPath filter for finding all type name with dedicated formattings
$XPath = "/Types/Type/Name"

#Retrieving the the data
Select-Xml -Path $Path -XPath $Xpath | Select-Object -ExpandProperty Node

#XPath filter for finding all types with dedicated formattings
$XPath = "//Types/Type"

#Retrieving the the data
$ListOfTypes = Select-Xml -Path $Path -XPath $Xpath | Select-Object -ExpandProperty Node

#Displaying all Types with its Members
$ListOfTypes 

#endregion


#region formatting types

#Path for Type formattings
$Path = "$Pshome\Types.ps1xml"

#XPath filter for finding all types with dedicated formattings
$XPath = "//Types/Type"

#Retrieving the the data
$ListOfTypes = Select-Xml -Path $Path -XPath $Xpath | Select-Object -ExpandProperty Node

#Finding the type with Get-Member
Get-Service | Get-Member #TypeName: System.ServiceProcess.ServiceController

#Retrieve the dedicated formatting type for services
$Type_for_Win32_Service = $ListOfTypes | Where-Object {$_.Name -like 'System.ServiceProcess.ServiceController'}

#Taking a look at the default property names
$Type_for_Win32_Service.Members.MemberSet.Members.PropertySet.ReferencedProperties.Name

#Rerieving the first service with standard formatting
(Get-Service)[0]

#Taking a look at all available properties
(Get-Service)[0] | Select-Object * | Format-Table 

#Another way to retrieve the TypeData
Get-TypeData | Where-Object {$_.TypeName -like 'System.ServiceProcess.ServiceController'}

#endregion