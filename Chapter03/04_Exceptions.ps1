# Non-terminating
Get-Item -Path C:\Does\not\exist
<#
Generates exception and continues with the rest of the script
Get-Item : Cannot find path 'C:\Does\not\exist' because it does not exist.
At line:1 char:1
+ Get-Item -Path C:\Does\not\exist
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : ObjectNotFound: (C:\Does\not\exist:String) [Get-Item], ItemNotFoundException
+ FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.GetItemCommand
#>

# Cmdlets return partial data with non-terminating exceptions
$items = Get-Item -Path C:\Does\Not\Exist, C:\Windows, $env:APPDATA
$items.Count # 2 folders retrieved

$error[0] # always retrieves the most recent exception

# Terminating
$items = Get-Item -Path C:\Does\Not\Exist, C:\Windows, $env:APPDATA -ErrorAction Stop
$items.Count # 0, Cmdlet terminated after the first error

# Make all errors terminating
$ErrorActionPreference = 'Stop'

# Handling terminating errors
try
{
    $items = Get-Item -Path C:\Does\Not\Exist, C:\Windows, $env:APPDATA -ErrorAction Stop
}
catch [System.Management.Automation.ItemNotFoundException]
{
    # Specific catch block for the exception type
    # PSItem contains the error record, and TargetObject may contain the actual object raising the error
    Write-Host ('Could not find folder {0}' -f $PSItem.TargetObject)
}
finally
{
    # Regardless of whether an error occurred or not, the optional
    # finally block is always executed.
    Write-Host 'Always executed'
}

