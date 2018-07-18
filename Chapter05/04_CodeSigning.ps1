#region Code signing

# A certificate is necessary
# Certificates can be self-signed, externally sourced, ...
$codeSigningCert = Get-ChildItem Cert:\CurrentUser\my -CodeSigningCert

# You can sign ps1, psd1, psm1 and mof files - any files that
# support Subject Interface Package (SIP)
New-Item -ItemType File -Path .\SignedScript.ps1 -Value 'Get-Process -Id $Pid'
Set-AuthenticodeSignature -FilePath .\SignedScript.ps1 -Certificate $codeSigningCert -IncludeChain all

# You can always validate a signature

# Valid
Get-AuthenticodeSignature -FilePath .\SignedScript.ps1
(Get-Content -Path .\SignedScript.ps1) -replace 'Get-Process', 'Stop-Process' | Set-Content .\SignedScript.ps1

# Hash mismatch - script has been altered
Get-AuthenticodeSignature -FilePath .\SignedScript.ps1
#endregion

#region Self-signed certificates

# The PKI module is not yet available for PowerShell core
# While .NET core supports creating self-signed certificates
# the module does not work in PowerShell core

# SSL
# Windows PowerShell
New-SelfSignedCertificate -DnsName "host.domain.internal", "domain.com" -CertStoreLocation "cert:\LocalMachine\My"

# PowerShell Core on Windows
$rootArguments = @(
    '-r'                 # Generate self-signed
    '-pe'                # Private key exportable
    '-n "CN=OnTheFlyCA"' # Name
    '-ss CA'             # Cert store
    '-a sha256'          # Hash algorithm
    '-sky signature'     # Key spec. Here: Digital Signature
    '-cy authority'      # Certificate type. Here: CA
    '-sv CA.pvk'         # Key file
    'CA.cer'             # Output file
)
Start-Process -FilePath makecert -ArgumentList $rootArguments -Wait -NoNewWindow

$sslArguments = @(
    '-pe'
    '-n "host.domain.internal"'
    '-a sha256'
    '-sky Exchange'
    '-eku 1.3.6.1.5.5.7.3.1' # Enhanced key usage
    '-ic CA.cer' # Issuer certificate
    '-iv CA.pvk' # Issuer key
    '-sp "Microsoft RSA SChannel Cryptographic Provider"'
    '-sy 12'
    '-sv server.pvk'
    'server.cer'
)
Start-Process -FilePath makecert -ArgumentList $sslArguments -Wait -NoNewWindow

# Generate Personal Information Exchange (pfx)
pvk2pfx -pvk server.pvk -spc server.cer -pfx server.pfx

# PowerShell Core on Unix

# Generates a new Certificate Signing Request and stores the
# private key to privkey.pem
sudo openssl req -new > sslcert.csr

# Generate a new private key - the one you need to protect
sudo openssl rsa -in privkey.pem -out server.key

# Generate an x509 certificate signed by our private key
# sslcert.cert is your public SSL certificate
sudo openssl x509 -in sslcert.csr -out sslcert.cert -req -signkey server.key -days 365

# Code signing
New-SelfSignedCertificate -Subject "CN=CodeSigningIsGreat" `
-KeyAlgorithm RSA `
-KeyLength 2048 `
-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
-KeyExportPolicy Exportable `
-KeyUsage DigitalSignature `
-Type CodeSigningCert

# Document encryption (for CMS or DSC)
New-SelfSignedCertificate -Subject 'CN=signer@company.com' -KeyUsage KeyEncipherment -CertStoreLocation Cert:\CurrentUser\My -Type DocumentEncryptionCert

#endregion

#region Signing and execution policies

# Show execution policy and source of it
Get-ExecutionPolicy -List

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process

# Start Shell with specific execution policy
pwsh.exe -ExecutionPolicy Bypass

# Executing scripts with broken signature (tampered scripts) in AllSigned mode
Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope Process

$codeSigningCert = Get-ChildItem Cert:\CurrentUser\my -CodeSigningCert
New-Item -ItemType File -Path .\ValidScript.ps1 -Value 'Get-Process -Id $Pid'
Set-AuthenticodeSignature -FilePath .\ValidScript.ps1 -Certificate $codeSigningCert -IncludeChain all

(Get-Content -Path .\ValidScript.ps1) -replace 'Get-Process', 'Stop-Process' | Set-Content .\ValidScript.ps1

# Script execution will now generate an error
.\ValidScript.ps1

#endregion

#region proving changes

# signed scripts
$codeSigningCert = Get-ChildItem Cert:\CurrentUser\my -CodeSigningCert
New-Item -ItemType File -Path .\ValidScript.ps1 -Value 'Get-Process -Id $Pid'
Set-AuthenticodeSignature -FilePath .\ValidScript.ps1 -Certificate $codeSigningCert -IncludeChain all

(Get-Content -Path .\ValidScript.ps1) -replace 'Get-Process', 'Stop-Process' | Set-Content .\ValidScript.ps1
Get-AuthenticodeSignature -FilePath .\ValidScript.ps1

# File hashes
$folder = New-Item -ItemType Directory -Path .\ManyScripts -Force
[void] ((1..100).ForEach({New-Item -Path $folder.FullName -Name "Script$_.ps1" -ItemType File -Value 'Hash me' -Force}))
New-FileCatalog -Path $folder.FullName -CatalogFilePath . -CatalogVersion 2

Set-Content -Path (Join-Path $folder.FullName Script1.ps1) -Value 'Changed'
Test-FileCatalog -Path $folder.FullName -CatalogFilePath .\catalog.cat

#endregion