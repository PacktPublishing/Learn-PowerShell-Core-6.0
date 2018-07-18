# Crafting a template for a simple storage account
$template = @{
    '$schema'      = "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
    contentVersion = '1.0.0.0'
    resources      = @(
        @{
            type       = 'Microsoft.Storage/storageAccounts'
            name       = "contoso$((1..8 | ForEach-Object { [char[]](97..122) | Get-Random }) -join '')"
            apiVersion = '2016-01-01'
            location   = 'westeurope'
            sku        = @{
                name = 'Standard_LRS'
            }
            kind       = 'Storage'
        }
    )
}

# You can script your template and when done, export to JSON
$template | ConvertTo-Json -Depth 100 | Out-File -FilePath .\StorageAccountStatic.json -Encoding UTF8

# Create a new resource group
$resourceGroupName = 'NastroAzzurro'
$location = 'westeurope'
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# Deploy your JSON template into the new resource group
$deployment = @{
    Name              = 'FirstDeployment'
    ResourceGroupName = $resourceGroupName
    TemplateFile      = '.\StorageAccountStatic.json'
    Verbose           = $true
}

New-AzureRmResourceGroupDeployment @deployment

# Extend the existing template by parameters and variables
$template.parameters = @{
    storageAccountType = @{
        type          = 'string'
        allowedValues = @(
            'Standard_LRS',
            'Standard_ZRS'
        )
        metadata      = @{
            description = 'The type of storage account. Mandatory.'
        }
    }
    location           = @{
        type         = 'string'
        defaultValue = $location
        metadata     = @{
            description = 'Location for all resources.'
        }
    }
}

$template.variables = @{
    storageAccountName = "contoso$((1..8 | ForEach-Object { [char[]](97..122) | Get-Random }) -join '')"
}

# Reference variables and parameters
$template.resources[0].name = "[variables('storageAccountName')]"
$template.resources[0].location = "[parameters('location')]"
$template.resources[0].sku.name = "[parameters('storageAccountType')]"

# Export and deploy again
$template | ConvertTo-Json -Depth 100 | Out-File -FilePath .\StorageAccountParameter.json -Encoding UTF8

$deployment = @{
    Name              = 'SecondDeployment'
    ResourceGroupName = $resourceGroupName
    TemplateFile      = '.\StorageAccountParameter.json'
    Verbose           = $true
}

# Use your template parameters in the resource group deployment!
New-AzureRmResourceGroupDeployment @deployment -location 'westeurope' -storageAccountType 'Standard_LRS'

# Using functions in the template
$template.variables = @{
    # Two functions at once. Concatenate contoso with a
    # unique string. The hash function uniqueString requires a seed
    # which is our resource group GUID
    storageAccountName = "[concat('contoso', uniquestring(resourceGroup().id))]"
}

# Export and deploy again
$template | ConvertTo-Json -Depth 100 | Out-File -FilePath .\StorageAccountFunctions.json -Encoding UTF8

$deployment = @{
    Name              = 'ThirdDeployment'
    ResourceGroupName = $resourceGroupName
    TemplateFile      = '.\StorageAccountFunctions.json'
    Verbose           = $true
}

# Use your template parameters in the resource group deployment!
New-AzureRmResourceGroupDeployment @deployment -location 'westeurope' -storageAccountType 'Standard_LRS'

# Clean up
Remove-AzureRmResourceGroup $resourceGroupName -Force