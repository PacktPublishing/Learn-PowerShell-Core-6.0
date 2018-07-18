# First things first
git clone https://github.com/automatedlab/dscworkshop

# Explore the repository
Set-Location -Path .\DscWorkshop\DscSample
Get-ChildItem

# Create the first build and download dependencies
.\.build.ps1 -ResolveDependency

# Explore the final code

# The DSC composite resources
Get-ChildItem .\DSC_Configurations

# And the configuration data
Get-ChildItem -File -Recurse -Path .\DSC_ConfigData

# ConfigurationData
# Data is used automatically during build
$configData = New-DatumStructure -DefinitionFile .\DSC_ConfigData\Datum.yml

# While you can lookup everything with hard-coded values like the environment...
$configData.AllNodes.Dev.DSCFile01.LCM_config.Settings.ConfigurationMode

# Datum will automatically do the lookup for you!
# interactively (without the automatic node reference)
Lookup -PropertyPath LCM_Config/Settings/ConfigurationMode -Node DSCFile01 -DatumTree $configData

# fully automatic inside your DSC config!
configuration SampleDoNotCompile
{
    # Node reference is retrieved automatically through $Node
    # Data is retrieved depending on the environment and role of the node
    $domainName = Lookup Domain/DomainName
}

# Examining the MOF files and RSOP
Get-ChildItem -Path .\BuildOutput -Recurse -File -Filter DSCFile01.yml
    Select-Object -First 1