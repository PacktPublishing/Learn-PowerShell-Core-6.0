<#
Sample taken from https://github.com/AutomatedLab/AutomatedLab where
it is used to create DSC pull servers in a lab environment
#>

$ComputerName = 'PullServer01'
$CertificateThumbPrint = (Get-ChildItem Cert:\LocalMachine\my -SSLServerAuthentication)[-1].Thumbprint
$RegistrationKey = (New-Guid).Guid

Configuration SetupDscPullServer
{
    param  
    ( 
        [string[]]$NodeName = 'localhost', 

        [ValidateNotNullOrEmpty()] 
        [string]$CertificateThumbPrint,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $RegistrationKey
    ) 

    LocalConfigurationManager
    {
        RebootNodeIfNeeded             = $false
        ConfigurationModeFrequencyMins = 15
        ConfigurationMode              = 'ApplyAndAutoCorrect'
        RefreshMode                    = 'PUSH'
    }

    Import-DSCResource -ModuleName xPSDesiredStateConfiguration, PSDesiredStateConfiguration

    Node $NodeName 
    { 
        WindowsFeature DSCServiceFeature
        { 
            Ensure = 'Present'
            Name   = 'DSC-Service'
        } 

        # The module xPSDesiredStateConfiguration is used to create the
        # pull server with the correct settings
        xDscWebService PSDSCPullServer 
        { 
            Ensure                   = 'Present'
            EndpointName             = 'PSDSCPullServer'
            Port                     = 8080
            PhysicalPath             = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint    = $certificateThumbPrint
            #CertificateThumbPrint   = 'AllowUnencryptedTraffic'
            ModulePath               = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath        = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                    = 'Started'
            UseSecurityBestPractices = $false
            DependsOn                = '[WindowsFeature]DSCServiceFeature'
        } 

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        }
    }
}

SetupDscPullServer -CertificateThumbPrint $CertificateThumbPrint -RegistrationKey $RegistrationKey -NodeName $ComputerName -OutputPath C:\Dsc | Out-Null

Start-DscConfiguration -Path C:\Dsc -Wait

# Prepare configurations for the pull clients
configuration HostedConfig1
{
    node localhost
    {
        File Pulled
        {
            DestinationPath = 'C:\File'
            Contents        = 'Pulled from elsewhere'
        }
    }
}
HostedConfig1

Rename-Item .\HostedConfig1\localhost.mof -NewName HostedConfig1.mof

# Place the configurations in the correct folder and generate checksums automatically
Publish-DscModuleAndMof -Source .\HostedConfig1

# After the pull server is configured, new clients can receive the pull configuration
[DscLocalConfigurationManager()]
configuration MetaConfig
{
    param
    (
        [string[]]$ComputerName,

        $PullServerFqdn,

        $RegistrationKey
    )

    node $ComputerName
    {
        Settings
        {
            RefreshMode = 'Pull'
        }

        ConfigurationRepositoryWeb IIS
        {
            ServerURL          = "https://$($PullServerFqdn):8080/PSDSCPullServer.svc"
            RegistrationKey    = $RegistrationKey
            ConfigurationNames = 'HostedConfig1'
        }
    }
}
MetaConfig -ComputerName DscNode01 -PullServerFqdn $ComputerName -RegistrationKey $RegistrationKey

Set-DscLocalConfigurationManager -Path .\MetaConfig -Verbose
Update-DscConfiguration -CimSession DscNode01 -Wait -Verbose