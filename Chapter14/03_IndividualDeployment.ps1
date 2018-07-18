$resourceGroupName = 'Blau'
$storageAccountName = "contoso$((1..8 | ForEach-Object { [char[]](97..122) | Get-Random }) -join '')"
$location = 'westeurope'
$vmName = 'MyFirstVm'
$roleSize = 'Standard_DS2'
$cred = Get-Credential

New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -SkuName Standard_LRS -Location $location
$storageContext = (Get-AzureRmStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName).Context
$container = New-AzureStorageContainer -Name disks -Context $storageContext
$rnd = (Get-Random -Minimum 1 -Maximum 1000).ToString('0000')
New-AzureRmVirtualNetwork -Name $resourceGroupName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix "10.0.0.0/16"    
Get-AzureRmVirtualNetwork -Name $resourceGroupName -ResourceGroupName $resourceGroupName |
    Add-AzureRmVirtualNetworkSubnetConfig -Name someSubnet -AddressPrefix '10.0.0.0/24' |
    Set-AzureRmVirtualNetwork

$subnet = Get-AzureRmVirtualNetwork -Name $resourceGroupName -ResourceGroupName $resourceGroupName |
    Get-AzureRmVirtualNetworkSubnetConfig

$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $RoleSize -ErrorAction Stop -WarningAction SilentlyContinue
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate -ErrorAction Stop -WinRMHttp
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsServer' -Offer WindowsServer -Skus 2016-Datacenter -Version "latest" -ErrorAction Stop -WarningAction SilentlyContinue

$networkInterface = New-AzureRmNetworkInterface -Name VmNic -ResourceGroupName $resourceGroupName -Location $location -Subnet $subnet
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $networkInterface.Id -ErrorAction Stop -WarningAction SilentlyContinue

$DiskName = "$($vmName)_os"
$OSDiskUri = "$($StorageContext.BlobEndpoint)disks/$DiskName.vhd"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $DiskName -VhdUri $OSDiskUri -CreateOption fromImage -ErrorAction Stop -WarningAction SilentlyContinue
    
$vmParameters = @{
    ResourceGroupName = $ResourceGroupName
    Location          = $Location
    VM                = $vm
    ErrorAction       = 'Stop'
    WarningAction     = 'SilentlyContinue'
}
New-AzureRmVM @vmParameters

# Examine your VM, add a public IP, allow WinRM traffic, ...

# Once finished, clean up
Remove-AzureRmResourceGroup $resourceGroupName -Force