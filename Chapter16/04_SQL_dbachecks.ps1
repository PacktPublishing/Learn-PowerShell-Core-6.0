Find-Module dbachecks

Install-Module dbachecks

# Execute only the PowerPlan check
Invoke-DbcCheck -Check PowerPlan

# Execute all instance-related checks
Invoke-DbcCheck -Check Instance

#region Configuration

Get-DbcConfig

Set-DbcConfig -Name policy.whoisactive.database -Value dba

##

# Export current settings
Export-DbcConfig -Path C:\dbachecks_config\production_config.json

# Import settings from file
Import-DbcConfig -Path C:\dbachecks_config\production_config.json -Temporary

#endregion

#region Feel the Power

# Import current configuration
Import-DbcConfig -Path C:\dbachecks_config\production_config.json -Temporary

# Run all tests and export data
Invoke-DbcCheck -AllChecks -Show Fails -PassThru |
    Update-DbcPowerBiDataSource -Environment Production

# Start PowerBI with data loaded and dashboard preconfigured
Start-DbcPowerBI

#endregion