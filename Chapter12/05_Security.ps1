# Generating certificates for remote nodes
$certPath = '.\DscCertificates'

# Generate the certificates to encrypt/decrypt data
$certParam = @{
    Type = 'DocumentEncryptionCertLegacyCsp'
    DnsName = 'TargetNode01'
}
$cert = New-SelfSignedCertificate @certParam

# Export private key and copy to node
$pfxPassword = Read-Host -AsSecureString
$cert | Export-PfxCertificate -FilePath "$env:temp\TargetNode01.pfx" -Password $pfxPassword -Force
$thumbprint = $cert.Thumbprint

# Export the public key to a file and remove the private key
$cert | Export-Certificate -FilePath (Join-Path $certPath 'TargetNode01.cer') -Force
$cert | Remove-Item -Force

# Use the certificate in your configuration by using ConfigurationData
$certFile = Get-Item .\DscCertificates\TargetNode01.cer


configuration WithCredential
{
    node localhost
    {
        File authenticationNeeded
        {
            Credential = new-object pscredential('user',('pass' | convertto-securestring -asplain -force))
            SourcePath = '\\contoso.com\databaseconfigs\db01.ini'
            DestinationPath = 'C:\db01.ini'
        }
    }
}

$cData = @{
    AllNodes = @(
        @{
            NodeName = 'TargetNode01'
            
            # This is necessary for the build machine to encrypt data
            CertificateFile = $certFile.FullName
        }
    )
}

WithCredential -ConfigurationData $cData