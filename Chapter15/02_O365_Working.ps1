
#Showing all cmdlets
Get-Command -Module AzureAD

#Retrieving all user information
Get-AzureADUser | Select-Object *

#Showing examples for dedicated cmdlets
Get-Help New-AzureADUser -Examples

#Creating new user 
New-AzureADUser -DisplayName "David" -UserPrincipalName "David@example.com" -AccountEnabled $true -MailNickName "Dave" -PasswordProfile $passwortProfile

#Creating new user using splatting
$HashArguments = @{
    DisplayName = "test.txt"
    UserPrincipalName = "test2.txt"
    AccountEnabled = $true
    MailNickName = "Dave"
    PasswordProfile = $passwortProfile
  }

New-AzureADUser @HashArguments

#Grouping user to region and Country
Get-AzureADUser | Group-Object Region 
Get-AzureADUser | Group-Object Country

#Retrieving all users grouped to Region
Get-AzureADUser | Group-Object Region | Sort-Object Count -Descending

#Retrieve UPNs
Get-AzureADUser | Sort-Object UserPrincipalName | Select-Object UserPrincipalName 

#Change user properties
Set-AzureADUser -ObjectID "David@Example.com" -UsageLocation "DE"

#Setting properties for specific user groups
Get-AzureADUser | Where-Object {$_.Department -eq "Development"} | Set-AzureADUser -UsageLocation "US"

