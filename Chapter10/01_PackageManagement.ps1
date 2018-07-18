# Module cmdlets
Get-Command -Module PackageManagement

# Interacting with repositories

# You have different package sources that you can add and remove
Get-PackageSource

# These sources are powered by different providers
Get-PackageProvider

# In order to find packages, narrow down by provider
# You can locate binary packages
Find-Package -Name notepadplusplus -ProviderName Chocolatey

# and PowerShell modules
Find-Package -Name AutomatedLab -ProviderName PowerShellGet


# When interacting with package providers, you can install specific versions
# and additional providers
Install-PackageProvider -Name nuget -MinimumVersion 2.8.5.208
Find-PackageProvider

# Installing packages is straightforward
Find-Package -Name AutomatedLab,notepadplusplus | Install-Package
Install-Package -Name datum

# Save package to inspect its contents
Save-Package notepadplusplus -Path .\npp -Force -Verbose

# Remove previously installed packages
Uninstall-Package -Name notepadplusplus
