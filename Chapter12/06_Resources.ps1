#region Built-in resource
# Really built-in
Get-DscResource -Module PSDesiredStateConfiguration

# New and improved (and updateable)
Get-DscResource -Module PSDscResources
#endregion

#region Community resources

# The x denotes experimental, while a c indicates a community resource
Find-DscResource -Name xMaintenanceWindow

# If a fitting module is found, install with Install-Module
Find-DscResource xMaintenanceWindow | Install-Module

# Discover additional resources in a module
Get-DscResource -Module xDscHelper

# There are some HQRM (High-quality resource modules) that are
# really extensive and are held to a higher coding standard
# https://github.com/powershell/dscresources
Find-DscResource -Name SqlSetup,SqlDatabase

# using resources
configuration withCustomResources
{
    Import-DscResource -ModuleName xDscHelper
    Import-DscResource -ModuleName PsDscResources

    xMaintenanceWindow mw
    {
        # Maintenance Window between 23:00 and 06:00
        ScheduleStart = [datetime]::Today.AddHours(23)
        ScheduleEnd = [datetime]::Today.AddHours(6)
        # First tuesday of a month
        DayOfWeek = 'Tuesday'
        DayOfMonth = 1
        ScheduleType = 'Monthly'
    }

    File f
    {
        DestinationPath = 'C:\somefile'
        DependsOn = '[xMaintenanceWindow]mw'
    }
}

# Roll you own resource module with resources
$resourceProperties = @(
    # Each resource needs one key - the indexing property
    New-xDscResourceProperty -Name Path -Type String -Attribute Key -Description 'The path to clean up'
    New-xDscResourceProperty -Name FileAge -Type DateTime -Attribute Required -Description 'The maximum file age (last modified)'
)

# Creates your resource module folder (xFileResources)
# with a subfolder DSCResources containing your resource, xFileCleaner
New-xDscResource -Name xFileCleaner -Property $resourceProperties -Path .\xFileResources

# Examine the folder contents
ls -r .\xFileResources
#endregion

#region Composite Resources

# The folder structure reminds us of MOF-based resource modules
# MyInfrastructureResources
#         ---> MyInfrastructureResources.psd1
#         ---> MyInfrastructureResources.psm1
#         ---> DscResources
#                  ---> SqlConfiguration
#                           ---> SqlConfiguration.psd1
#                           ---> SqlConfiguration.psm1

configuration HidingTheComplexity
{
    param
    (
        $DatabaseName,

        $Collation
    )

    Import-DscResource -ModuleName MyInfrastructureResources

    SqlConfiguration SqlConfig
    {
        DatabaseName = 'MyAwesomeDb'
        Collecation = 'Some crazy collation'
    }
}

#endregion
