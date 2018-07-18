#Showing all cmdlets
Get-Command -Module MicrosoftTeams

#List up all teams with all properties
Get-Team | Select-Object *

#Create new teams
$returnedInformation = New-Team -DisplayName "PowerShell Professionals" -AccessType Private

#Inspecting the cmdlet
Get-Team | Get-Member

#Retrieving the created team
Get-Team | Where-Object {$_.DisplayName -eq "PowerShell Professionals"} 
Get-Team | Where-Object {$_.GroupId -eq $returnedInformation.GroupId} 

#Making changes to the team
Get-Team | Where-Object {$_.DisplayName -eq "PowerShell Professionals"} | Set-Team -DisplayName 'Changed'
Get-Team | Where-Object {$_.DisplayName -eq "Changed"} 

#Adding user to a specific team
Add-TeamUser -GroupId $returnedInformation.GroupId -User 'jan@example.de' -Role 'Owner'

#Retrieving team users
Get-TeamUser -GroupId $returnedInformation.GroupId 

#Remove a team
Remove-Team -GroupId $returnedInformation.GroupId
Remove-Team -GroupId 'f9a51141-ee24-43a7-96c7-f0efb6c6e54a' #GUID
