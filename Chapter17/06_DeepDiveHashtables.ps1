#region PSDefaultParameterValues
# The automatic variable is great to set defaults
$labFolder = mkdir .\StagingDirectory -Force
$PSDefaultParameterValues = @{
    '*:Path' = $labFolder.FullName # Extremely generic. Set all Path parameters for all Cmdlets
    'New-Item:ItemType' = 'File'
}

# Notice how all cmdlets use Path
# New-Item uses ItemType File now
New-Item -Name someFile
Get-ChildItem
Test-Path
Join-Path -ChildPath SomePath
Get-Item
New-FileCatalog -CatalogFilePath here.cat

# Cmdlets can still override defaults
Add-Content -Path (Join-Path -ChildPath someFile) -Value 'Some data'

# Clear the defaults or remove single keys
$PSDefaultParameterValues.Remove('*:Path')
$PSDefaultParameterValues.Clear()

#endregion

#region PsBoundParameters
# Another cool dictionary to use
function Get-AllTheThings
{
    [CmdletBinding()]
    param
    (
        $Parameter1,

        $Parameter2
    )

    $PSBoundParameters | Out-Host
    Get-AllTheInternalThings @PSBoundParameters
}

function Get-AllTheInternalThings
{
    [CmdletBinding()]
    param
    (
        $Parameter1,

        $Parameter2
    )

    Write-Verbose -Message 'Pretty cool, eh?'
    Write-Host "Parameter1 was $Parameter1 and Parameter2 was $Parameter2"
}

# Calling Get-AllTheThings will pass all possible parameters
# on to Get-AllTheInternalThings.
Get-AllTheThings -Parameter1 1 -Parameter2 2 -Verbose

# Be careful: If parameters do not exist, you still get errors
function Get-AllTheInternalThings
{
     # Leave the parameter binding and all parameter attributes, and the bound
     # parameters will not throw an error ;)
    [CmdletBinding()]
    param
    (
        $Parameter1
    )
}
Get-AllTheThings -Parameter1 1 -Parameter2 2 -Verbose # Throws now...

#endregion