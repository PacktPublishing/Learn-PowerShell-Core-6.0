#Retrieves all available PSProviders
Get-PSProvider

#and exports them to a csv file
Get-PSProvider | Out-File c:\temp\PSProvider.txt

#Show all PSDrives
Get-PSDrive

#Export all PSDrives
Get-PSDrive | Export-Csv -Delimiter ';' -Path c:\temp\ExportedPSDrives.csv 