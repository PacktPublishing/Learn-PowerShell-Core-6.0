#Retrieve the ExecutionPolicy
Get-ExecutionPolicy

#Define it to Bypass
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

#Define it to Restricted
Set-ExecutionPolicy -ExecutionPolicy Restricted -Force

#Retrieve the Execution policies as list
Get-ExecutionPolicy -List | Format-Table -AutoSize

#execute a demo script
.\MyScript.ps1