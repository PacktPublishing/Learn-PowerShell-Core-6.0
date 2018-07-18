
#region working with JSON

#Exporting Services to JSON
$ServicesAsJSON = Get-Service | Select-Object -Property DisplayName, ServiceName, Status, StartType | ConvertTo-Json 

#Converting exported JSON object to hashtable
$importedServices = $ServicesAsJSON | ConvertFrom-Json 

#Show 
$importedServices | Out-GridView

#Different types
(Get-Service)[0].GetType() #ServiceController
$importedServices[0].GetType() #PSCustomObject
$importedServices.GetType() #HashTable -- Array

#Loading some JSON data into variable
$someJSONdata = '{"people":[
    { "firstName":"John", "lastName":"Doe" },
    { "firstName":"Jane", "lastName":"Dane" }
]}'

#Converting exported JSON object to hashtable
$ConvertedDataFromJSON = ConvertFrom-Json -InputObject $someJSONdata 

#Show
$ConvertedDataFromJSON.people | Out-GridView

#endregion


#region Get JSON strings from a web service and convert them to PowerShell objects

#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json

# Using TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Invoking web request to GitHub on the PowerShell repo and converting them to JSON
$gatheredPowerShellIssues = Invoke-WebRequest 'https://api.github.com/repos/PowerShell/PowerShell/issues' | ConvertFrom-Json

#Show
$gatheredPowerShellIssues | Out-GridView

#endregion

