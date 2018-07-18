# Imperative

Install-WindowsFeature -Name AD-Domain-Services, RSAT-AD-Tools -IncludeAllSubFeature

# What happens if the feature cannot be enabled in your build script?
$param = @{
    DomainName                    = 'contoso.com'
    SafeModeAdministratorPassword = Read-Host -AsSecureString -Prompt 'Safemode password'
    Credential                    = Get-Credential
    ForestMode                    = 'WinThreshold'
    NoRebootOnCompletion          = $true
}
Install-ADDSForest @param

# Declarative
configuration Domain
{
    param
    (
        [pscredential] $Credential
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory
    
    node $AllNodes.NodeName
    {
        foreach ($feature in @('AD-Domain-Services', 'RSAT-AD-Tools'))
        {
            WindowsFeature $feature
            {
                Name   = $feature
                Ensure = 'Present'
            }
        }

        xADDomain contoso
        {
            DomainName = 'contoso.com'
            DomainAdministratorCredential = $Credential
            SafemodeAdministratorPassword = $Credential
            ForestMode = 'WinThreshold'
            DependsOn = '[WindowsFeature]AD-Domain-Services', '[WindowsFeature]RSAT-AD-Tools'
        }
    }
}

# Compiling a configuration
$configurationData = @{
    AllNodes = @(
        @{
            NodeName = '*'
            PSDSCAllowPlaintextPassword = $true
            PSDSCAllowDomainUser = $true
        }
        @{
            NodeName = 'DC01'
        }
    )
}
Domain -Credential (Get-Credential) -ConfigurationData $configurationData

# For each node, one MOF file is created
# Notice that we allowed plaintext credentials
Get-Content .\Domain\DC01.mof

# We used ConfigurationData to set certain properties like
# allowing plaintext passwords and credentials
@{
    # AllNodes is predefined and will be available in $AllNodes
    AllNodes = @(
        @{
            # These settings are valid for all nodes
            NodeName = '*'
            PSDSCAllowPlaintextPassword = $true
            PSDSCAllowDomainUser = $true
        }
        @{
            # For each node one hashtable exists with specific settings
            NodeName = 'DC01'
            Role = 'DC'
            Features = 'AD-Domain-Services','RSAT-AD-Tools'
            
            # If a CertificateFile is used, the configuration will be encrypted
            # on the build system as well
            CredentialFile = 'C:\SomePublicKey.cer'
        }
    )

    # You can add additional keys to build out your data
    Domains = @{
        'contoso.com' = @{
            DFL = 5
            FFL = 5
        }
        'a.contoso.com' = @{
            DFL = 7
        }
    }
}

# Filtering AllNodes
configuration WithFilter
{
    node $AllNodes.Where({$_.Role -eq 'DC'}).NodeName
    {
        # DC specific stuff
    }

    node $AllNodes.Where({$_.Role -eq 'FileServer'}).NodeName
    {
        # File server specific stuff
    }
}