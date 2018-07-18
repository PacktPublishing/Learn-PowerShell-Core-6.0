#Reference: http://www.leeholmes.com/blog/2017/03/17/detecting-and-preventing-powershell-downgrade-attacks/

#v2 GAC MSIL 
powershell.exe -version 2 -noprofile -command "$(Get-Item ([PSObject].Assembly.Location)).VersionInfo"

#v2 Native
powershell.exe -version 2 -noprofile -command "(Get-Item $(Get-Process -id $pid -mo | Where-Object { $_.FileName -match 'System.Management.Automation.ni.dll' } | ForEach-Object { $_.FileName })).VersionInfo"

#v4 GAC MSIL
powershell.exe -noprofile -command "(Get-Item ([PSObject].Assembly.Location)).VersionInfo | Select *"

#v4 Native
powershell.exe -noprofile -command "(Get-Item $(Get-Process -id $pid -mo | Where-Object { $_.FileName -match 'System.Management.Automation.ni.dll' } | ForEach-Object { $_.FileName })).VersionInfo"

#Retrieving all dlls
(Get-ChildItem -Path c:\ -Filter *.dll -Recurse -ErrorAction Ignore).FullName | Where-Object { $_ -match 'System\.Management\.Automation\.(ni\.)?dll' }
