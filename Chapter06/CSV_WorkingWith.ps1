#Defining file for export
$exportedFile = 'C:\temp\exportedProcesses.csv'

#Exporting as CSV - basic
Get-Process | Export-Csv $exportedFile

#Opening the file
psedit $exportedFile

#Importing CSV  file
$data = Import-Csv $exportedFile

#Showing content
$data | Out-GridView

#Showing its type
$data | Get-Member #  TypeName: CSV:System.Diagnostics.Process
$data[0].GetType() #  PSCustomObject
$data.GetType()    #  System.Array

#Making use of type and filtering the data
$data | Where-Object { ($_.Name).Length -lt 7 } | Out-GridView

#Exporting as CSV with specified delimiter ';'
Get-Process | Export-Csv $exportedFile -Delimiter ';'

#Importing the data
$data = Import-Csv $exportedFile -Delimiter ';'

#Showing the data
$data | Out-GridView

#Create ComObject for Excel
$excel = New-Object -ComObject Excel.Application

#Make it visible
$excel.Visible = $true

#Open the CSV file
$excel.Workbooks.Open($exportedFile)
