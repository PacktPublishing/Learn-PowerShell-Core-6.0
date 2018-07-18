#Example of a cmdlet
# Do-Something
# Verb-Noun

#Retrieving Help and examples
Get-Help

#Retrieves all commands 
Get-Command

#Shows full help about the cmdlet Get-Command
Get-Help Get-Command -Full

#Downloads and updates the help on this computer - needs Admin rights
Update-Help

#Shows typical example for the cmdlet Get-Command
Get-Help Get-Service -Examples

#All command containing 'service'
Get-Command *service*

#Retrieves all cmdlets from the module Microsoft.PowerShell.Utility
Get-Command -Module Microsoft.PowerShell.Utility

#Shows all modules
Get-Module

#Retrieves member and typ of the object
Get-Member -InputObject 'string'

#Can also be piped to
'string' | Get-Member

#Approved verbs
Get-Verb

#############################################

#Getting in touch with important cmdlets
Get-Command Get-*
Get-Command Set-*
Get-Command New-*
Get-Command Out-*

#Example for Get-Process
Get-Help Get-Process -Examples
Get-Process powershell -FileVersionInfo

