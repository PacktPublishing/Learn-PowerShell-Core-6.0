
#Install PowerShell module for Teams
Install-Module MicrosoftTeams -Force

#Credentials to connect to online service
$UserCredential = Get-Credential -UserName 'David@example.de' -Message 'Password'

#Showing credentials
$UserCredential

#Connect to service with user name and password
#proving if the connection has been established correctly
try {
    Connect-MicrosoftTeams -Credential $UserCredential
    $connectionSuccessfullyEstablished = $true
}
catch {
    $connectionSuccessfullyEstablished = $false
}

#multifactor authentication 
Connect-MicrosoftTeams

#Disconnect - if more tenants are being managed
Disconnect-MicrosoftTeams

