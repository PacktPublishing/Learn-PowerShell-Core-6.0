#region working with services

#Defining file for export
$exportedFile = 'C:\temp\exportedServices.xml'

#Exporting services and strong into variable
Get-Service | Tee-Object -Variable exportedServices | Export-Clixml $exportedFile 

#Showing variable
$exportedServices 

#Importing services
$importedServices = Import-Clixml $exportedFile

#Comparing objects
Compare-Object -ReferenceObject $exportedServices -DifferenceObject $importedServices -Property Name, Status

#endregion

#region working with processes

#Defining file for export
$exportedFile = 'C:\temp\exportedProcesses.xml'

#Exporting services and strong into variable
Get-Process| Tee-Object -Variable exportedProcesses | Export-Clixml $exportedFile 

#Showing variable
$exportedProcesses

#Importing services
$importedProcesses = Import-Clixml $exportedFile

#Comparing objects - no difference should be visible
Compare-Object -ReferenceObject $exportedProcesses -DifferenceObject $importedProcesses -Property ProcessName, Id

#Starting another process - Notepad.exe
Notepad.exe

#Comparing objects with current process list
Compare-Object -ReferenceObject $exportedProcesses -DifferenceObject $(Get-Process) -Property ProcessName, Id

#endregion