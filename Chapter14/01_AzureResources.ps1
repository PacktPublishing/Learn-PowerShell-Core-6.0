# First things first
# Installing the Azure modules
# Pro tip: Get a coffee right now, this takes a little time...
Install-Module AzureRm -Force

# Before you can do anything, you need to login
Add-AzureRmAccount -Subscription 'JHPaaS'

#region Resources
# Listing your subscription's resources
Get-AzureRmResource

# These are as general as they get
$resources = Get-AzureRmResource | Group-Object -Property ResourceType -AsHashTable -AsString
$resources.'Microsoft.Storage/storageAccounts'

# Resource Groups - still pretty general
Get-AzureRmResourceGroup

# Typical IaaS resources

# Storage for Disks, Metrics, ...
Get-AzureRmStorageAccount

# VNets for your IaaS workloads
Get-AzureRmVirtualNetwork

# Network adapters for your IaaS VMs
Get-AzureRmNetworkInterface

# Public IP adresses for VMs/Load balancers/WAP
Get-AzureRmPublicIpAddress

# The OS offer for your VM
Get-AzureRmVMImagePublisher -Location 'westeurope' |
    Where-Object PublisherName -eq 'MicrosoftWindowsServer' |
    Get-AzureRmVMImageOffer |
    Get-AzureRmVMImageSku |
    Get-AzureRmVMImage |
    Group-Object -Property Skus, Offer

# A load balancer for multiple VMs - IPv4 addresses are rare!
Get-AzureRmLoadBalancer

# Finally, your VMs
Get-AzureRmVm
#endregion

#region Availability

# For a (at the time of writing buggy) overview of available resources
Get-AzureRmComputeResourceSku

# Filtering for available SKUs
$availableSkus = Get-AzureRmComputeResourceSku |
    Where-Object  {$_.Restrictions.ReasonCode -NotContains 'NotAvailableForSubscription'}

Get-AzureRmComputeResourceSku |
    Where-Object  {$_.Restrictions.ReasonCode -NotContains 'NotAvailableForSubscription'} |
    Group-Object -Property ResourceType -AsHashTable -AsString

# There are a couple other resource-availability related cmdlets
Get-Command -Noun Azure*Sku

<#
CommandType     Name
-----------     ----
Cmdlet          Get-AzureBatchNodeAgentSku
Cmdlet          Get-AzureRmApplicationGatewaySku
Cmdlet          Get-AzureRmComputeResourceSku
Cmdlet          Get-AzureRmIotHubValidSku
Cmdlet          Get-AzureRmVMImageSku
Cmdlet          Get-AzureRmVmssSku
Cmdlet          New-AzureRmApplicationGatewaySku
Cmdlet          Set-AzureRmApplicationGatewaySku
#>
#endregion