# Working with credentials

# Which cmdlets support credentials?
Get-Command -ParameterName Credential

# What is a credential in PowerShell?
# A combination of account and .NET SecureString object
$username = 'contoso\admin'
$password = 'P@ssw0rd' | ConvertTo-SecureString -AsPlainText -Force
$newCredential = New-Object -TypeName pscredential $userName, $password

$newCredential.GetType().FullName
$newCredential | Get-Member

# At first you can only see the reference to a SecureString object
$newCredential.Password

# Using GetNetworkCredential, it's plaintext again
$newCredential.GetNetworkCredential() | Get-Member
$newCredential.GetNetworkCredential().Password

# But this was possible anyways
[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newCredential.Password))

# Why use the plaintext password at all?
$cmd = 'cmdkey.exe /add:"TERMSRV/{0}" /user:"{1}" /pass:"{2}"' -f 'SomeHost', $newCredential.UserName, $newCredential.GetNetworkCredential().Password
Invoke-Expression $cmd | Out-Null
mstsc.exe "/v:SomeHost"

# Encrypting credentials at rest
# Add a new self-signed certificate for testing
New-SelfSignedCertificate -Subject SomeRecipient -KeyUsage KeyEncipherment -CertStoreLocation Cert:\CurrentUser\My -Type DocumentEncryptionCert

# Use the certificate to encrypt a message (public key of recipient required)
Protect-CmsMessage -to CN=SomeRecipient -Content (Read-Host -AsSecureString -Prompt 'Enter password' | ConvertFrom-SecureString) | Out-File .\EncryptedContent.txt

# Decrypt the message on another system (private key required
Unprotect-CmsMessage -Content (Get-Content .\EncryptedContent.txt -Raw) | ConvertTo-SecureString