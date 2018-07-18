#Working with CMS
Install-Module ProtectedData
 
#Testing purpose
New-SelfSignedCertificate -Subject PowershellSec -KeyUsage KeyEncipherment -CertStoreLocation Cert:\CurrentUser\My 
 
#Retrieving cert
$Cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like '*PowershellSec*'}
 
#Production
#$Cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -like 'CN=PowerShell Automation*'}
 
# Encrypt password and store it in a file.
Protect-Data 'Password' -Certificate $Cert | Export-Clixml .\encrypted.xml
 
# Decrypt password from file within script.
$PasswordToUse = Unprotect-Data (Import-Clixml .\encrypted.xml) -Certificate $Cert 
 
$PasswordToUse