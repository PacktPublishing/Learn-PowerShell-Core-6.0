

#region connecting with the Microsoft Azure Active Directory Module for Windows PowerShell

#Installing the Microsoft Azure Active Directory Module 
Install-Module MSOnline -Force

#Credentials to connect to online service
$UserCredential = Get-Credential -UserName 'David@example.de' 

#Showing credentials
$UserCredential

#Connect to service
Connect-MsolService -Credential $UserCredential

#proving if the connection has been established correctly
try {
    $connectionSuccessfullyEstablished = Get-MsolUser.Count -ge 0 
}
catch {
    $connectionSuccessfullyEstablished = $false
}

#https://docs.microsoft.com/en-us/powershell/module/msonline/?view=azureadps-1.0


####
#multifactor authentication 
Connect-MsolService

#endregion

#region connecting with the Azure Active Directory PowerShell for Graph module

#Installing the Microsoft Azure Active Directory Module 
Install-Module -Name AzureAD -Force

#Credentials to connect to online service
$UserCredential = Get-Credential -UserName 'David@example.de' -Message 'Password'

#Showing credentials
$UserCredential

#Connect to service
#proving if the connection has been established correctly
try {
    Connect-AzureAD -Credential $UserCredential
    $connectionSuccessfullyEstablished = $true
}
catch {
    $connectionSuccessfullyEstablished = $false
}

#https://docs.microsoft.com/de-de/powershell/module/Azuread/?view=azureadps-2.0

####
#multifactor authentication 
Connect-AzureAD

#Disconnect - if more tenants are being managed
Disconnect-AzureAD

#endregion



