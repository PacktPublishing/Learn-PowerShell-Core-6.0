# Code flagged by additional rules

# You should use the CIM cmdlets!
# PSAvoidUsingWMICmdlet
Get-WmiObject Win32_Process

# Don't leak passwords!
# PSAvoidUsingConvertToSecureStringWithPlainText)
$Credential = New-Object pscredential('user',('ClearTextPassword' | ConvertTo-SecureString -AsPlainText -Force))

# Use proper function names
# PSUseSingularNouns
function Get-SomeObjects
{

}

# Don't catch errors just to ignore them
# PSAvoidUsingEmptyCatchBlock
try
{ 
    Get-Item C:\DoesNotCompute -ErrorAction Stop
}
catch
{ }