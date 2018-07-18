# Trapping errors
# At the beginning of a script, a trap can be introduced to trap any terminating errors that
# are not handled.
trap
{
    Write-Host ('Could not find folder {0}' -f $PSItem.TargetObject)
    continue # or break
}

# Will not trigger the trap
$items = Get-Item -Path C:\Does\Not\Exist, C:\Windows, $env:APPDATA

# Will trigger the trap
$items = Get-Item -Path C:\Does\Not\Exist, C:\Windows, $env:APPDATA -ErrorAction Stop

# Additional code runs if trap statement uses continue
Write-Host 'This is not a good idea'