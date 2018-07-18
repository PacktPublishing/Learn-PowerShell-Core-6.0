#Defining the etl file
$etlFile = 'C:\Windows\Panther\setup.etl'

#Retrieving the content
$log = Get-WinEvent -Path $etlFile –Oldest

#Finding the ProviderName
$ProviderNames = $log | Select-Object Providername -Unique -ExpandProperty ProviderName

#Filtering 
$log.Where{$_.Providername -eq $($ProviderNames[1])}
$log | Where-Object {$_.ProviderName -eq "$($ProviderNames[0])"} | Select-Object -First 10
$log | Where-Object {$_.ProviderName -eq 'Microsoft-Windows-Services'} 

#Exporting the log data 
$log | Export-Csv c:\temp\etltest.csv -Delimiter ';'
$log | Export-Csv -Delimiter ';' -PipelineVariable $logcsvnew 

#Importing the log data
$logcsv = Import-Csv -Delimiter ';' -Path C:\temp\etltest.csv

#Filtering on the imported data
$logcsv | Select-Object -Property ProviderName -Unique
$logcsv[0].TimeCreated 