
#Sets the location to the registry path, which contains all the cleanup methods
Set-Location 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\'

#Runs through all keys and creates a new key with the name 'StateFlags1234' and the value 2
foreach ($item in $(Get-ChildItem).PSPath)
{
    #Skipping existing keys
    if (-not (Get-ItemProperty -Path $item -Name 'StateFlags1234'))
    {
        New-ItemProperty -Path $item -Name 'StateFlags1234' -Value 2
    }   
}

<#
Runs the cleanmgr.exe with the slag sagerun
It will run through all the keys in the previously set registry location and search for the keys 'Stateflags##ID##'
The value 2 sets this options to enabled - so every cleanup method is being executed.
#>
cleanmgr.exe /sagerun:1234 