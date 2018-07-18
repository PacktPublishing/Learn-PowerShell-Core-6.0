# ***************************************************************************
# 
# File:      RemoveUserApps.ps1
# 
# Version:   1.0 
# 
# Author:    Michael Niehaus 
#
# Purpose:   Removes apps installed for the user but not provisioned for the
#            device, to avoid sysprep failures.
#
# Usage:     This script can be added into any MDT or ConfigMgr task sequence,
#            and should be placed right before the sysprep step.
#
#            For this script to run, script execution must be enabled, e.g.
#            "Set-ExecutionPolicy Bypass".  This can be done via a separate
#            task sequence step if needed, see http://blogs.technet.com/mniehaus
#            for more information.
#
# ------------- DISCLAIMER -------------------------------------------------
# This script code is provided as is with no guarantee or waranty concerning
# the usability or impact on systems and may be used, distributed, and
# modified in any way provided the parties agree and acknowledge the 
# Microsoft or Microsoft Partners have neither accountabilty or 
# responsibility for results produced by use of this script.
#
# Microsoft will not provide any support through any means.
# ------------- DISCLAIMER -------------------------------------------------
#
# ***************************************************************************

# ---------------------------------------------------------------------------
# Get-LogDir:  Return the location for logs and output files
# ---------------------------------------------------------------------------

function Get-LogDir
{
  try
  {
    $ts = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
    if ($ts.Value("LogPath") -ne "")
    {
      $logDir = $ts.Value("LogPath")
    }
    else
    {
      $logDir = $ts.Value("_SMSTSLogPath")
    }
  }
  catch
  {
    $logDir = $env:TEMP
  }
  return $logDir
}


# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------

$logDir = Get-LogDir
Start-Transcript "$logDir\RemoveUserApps.log"

# Get the list of provisioned packages
$provisioned = Get-AppxProvisionedPackage -online

# Check each installed app
$count = 0

for ($i=1; $i -ile 2; $i++) {
  # Check each app (two loops just in case there are dependencies that can't be removed until the
  # main app is removed)
  Get-AppxPackage | ? {$_.SignatureKind -ne 'System'} | ForEach-Object {
    $current = $_
    $found = $provisioned | ? {$_.DisplayName -eq $current.Name -and $_.Version -eq $current.Version}
    if ($found.Count -eq 0)
    {
      Write-Host "$($current.Name) version $($current.Version) is not provisioned, removing."
      Remove-AppxPackage -Package $current.PackageFullName
      $count++
    }
  }
}
Write-Host "Number of apps removed: $count"

Stop-Transcript
