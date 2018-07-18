# Gets all services and pipes them into the cmdlet Stop-Service
# By using the flag -WhatIf it is not really executing the code, but showing what it would do.
Get-Service | Stop-Service -WhatIf

#Piping is very often to export data
Get-Service | Export-Csv -Path 'c:\temp\Services.csv'

#And also to visualize data
Get-Service | Out-GridView