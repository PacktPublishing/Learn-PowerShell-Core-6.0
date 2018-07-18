# Setting the LCM
[DscLocalConfigurationManager()]
configuration LcmMetaConfiguration
{
    node localhost
    {
        Settings # No name here, settings is unique to a node
        {
            ConfigurationMode = 'ApplyAndAutoCorrect'
            ConfigurationModeFrequencyMins = 30
            DebugMode = 'None'
            RebootNodeIfNeeded = $true
            ActionAfterReboot = 'ContinueConfiguration'
        }
    }
}
LcmMetaConfiguration
Set-DscLocalConfigurationManager -Path .\LcmMetaConfiguration
