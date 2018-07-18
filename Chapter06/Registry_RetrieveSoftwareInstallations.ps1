#registry path for 64bit software installations
$installations64bit = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{*}'

#registry path for 32bit software installations
$installations32bit = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{*}'

#retrieving all values and adding the architecture as a additonal NoteProperty to it
$allInstalledSoftwareInstallations = @(Get-ItemProperty -Path $installations64bit | Add-Member -MemberType NoteProperty -Name Architecture -Value '64bit' -PassThru)
$allInstalledSoftwareInstallations += Get-ItemProperty -Path $installations32bit | Add-Member -MemberType NoteProperty -Name Architecture -Value '32bit' -PassThru

#Show all instaled software installations sorted on the display name
$allInstalledSoftwareInstallations | 
  Select-Object -Property DisplayName, DisplayVersion, UninstallString, Architecture |
  Sort-Object -Property DisplayName |
  Out-GridView