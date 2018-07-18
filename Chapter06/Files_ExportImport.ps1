#Storing working location
$exportedProcessesPath = 'C:\temp\exportedProcesses.txt'

# region writing to file

#Write processes table to file and show the result in terminal with the -PassThru flag
Get-Process | Set-Content -Path $exportedProcessesPath 

#Open file to verify
psedit $exportedProcessesPath

#retrieving proces and exporting them to file
Get-Process | Out-File $exportedProcessesPath 

#Open file to verify
psedit $exportedProcessesPath

#retrieving processes and exporting them to file with Out-String
Get-Process | Out-String | Set-Content $exportedProcessesPath -PassThru

#Open file to verify
psedit $exportedProcessesPath

#endregion

# region writing to file using econdings

#retrieving process and exporting them to file with encoding
Get-Process | Out-String | Set-Content $exportedProcessesPath -PassThru -Encoding UTF8

Get-Process | Out-String | Set-Content $exportedProcessesPath -PassThru -Encoding Byte

#endregion

#region loading content

#Retrieving the content
$data = Get-Content $exportedProcessesPath 

#The last 5 lines
Get-Content -Path $exportedProcessesPath -Tail 5

#The first 5 lines
Get-Content -Path $exportedProcessesPath -TotalCount 5

#Get-Content with ReadCount, because of perfomance-improvement.
$data = (Get-Content -Path $exportedProcessesPath -ReadCount 1000)

#Splitting the lines if parsing
$data = (Get-Content -Path $exportedProcessesPath -ReadCount 1000).Split([Environment]::NewLine)

#Retrieving data as one large string
$data = Get-Content -Path $exportedProcessesPath -Raw

#endregion

