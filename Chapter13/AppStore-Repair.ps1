#Retrieve Apps examples
Get-AppxPackage | Select-Object Name, PackageFullName

#Retrieving and removing
Get-AppxPackage *3dbuilder* | Remove-AppxPackage -WhatIf
Get-AppxPackage -AllUsers | Remove-AppxPackage -WhatIf
Get-AppxPackage | where-object {$_.name –notlike "*store*"} | Remove-AppxPackage


#Retrieve provisioned apps 
Get-ProvisionedAppxPackage -Online

#Removing a specific provisioned app
Remove-AppxProvisionedPackage -Path c:\offline -PackageName MyAppxPkg

#Reregistering Windows Store apps
Get-AppXPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

#Reregistering all apps
Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}