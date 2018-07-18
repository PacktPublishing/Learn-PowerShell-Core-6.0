# Enabling remoting

# Enabled by default on Windows Server 2012R2 and newer
# Always disabled on Client SKUs
# Can be enabled by installing the omi-psrp-server on Linux

# Windows
Enable-PSRemoting

# CentOS/RHEL
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
sudo yum install powershell
sudo yum install omi-psrp-server


# Cmdlets capable of remoting
Get-Command -ParameterName ComputerName,CimSession,Session,PSSession

# Cmdlets with the ComputerName parameter usually use DCOM/RPC to communicate
# Steer clear of those, as they are slower and getting firewall exceptions is harder
Get-Service -ComputerName Machine1

# Cmdlets that can use sessions work with PowerShell remoting or CIM remoting
Get-DscConfiguration -CimSession Machine1
Copy-Item -FromSession Machine1 -Path C:\file -Destination C:\file

# What are sessions? We can have two types

# WinRM/PSRP-Sessions
# The default authentication option is Negotiate, where we try Kerberos first
$pwshSession = New-PSSession -ComputerName Machine1

# If alternate credentials are needed you can add them as well
$credentialSession = New-PSSession -ComputerName Machine2 -Credential contoso\SomeAdmin

# Sometimes, you need to access a machine via SSL or you want to set different session options
$linuxOptions = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$linuxSession = New-PSSession -ComputerName Centos1 -SessionOption $linuxOptions -Authentication Basic -Credential root -UseSSL

# Session options can also be relevant when products like the SQL Server Reporting services
# add a HTTP SPN that effectively breaks your Kerberos authentication with the remote
$sessionOption = New-PSSessionOption -IncludePortInSPN
$session = New-PSSession -ComputerName SSRS1 -SessionOption $sessionOption

# CIM sessions
# CIM remoting enables you to retrieve all kinds of data from remote systems
# CIM is not limited to Windows, but currently implemented in most Windows PowerShell cmdlets
$cimSession = New-CimSession -ComputerName someMachine # Still using WinRM as a transport protocol
Get-NetAdapter -CimSession $cimSession
Get-DscConfiguration -CimSession $cimSession
Get-CimInstance -ClassName Win32_Process -CimSession $cimSession

# Remoting types

# Interactive, 1:1
# Session is created, used interactively and exited
Enter-PSSession -ComputerName Machine1
Get-Host
Exit-PSSession

# 1:n
$sessions = New-PSSession -ComputerName Machine1,Machine2,MachineN

# Persistent sessions, Invoke-Command uses 32 parallel connections
# Can be controlled with ThrottleLimit
Invoke-Command -Session $sessions -ScriptBlock {
    $variable = "value"
}

# Persistent sessions can be used multiple times until the idle timeout
# destroys the session on the target machine
Invoke-Command -Session $sessions -ScriptBlock {
    Write-Host "`$variable is still $variable"
}

# Persistent sessions can even be reconnected to if PowerShell has been closed
# If the same authentication options are used, a reconnect is possible
Get-PSSession -ComputerName Machine1

# DisconnectedScope
# Invoke-Command can run in a disconnected session that can be connected
# from any other machine on the network unless it is already connected
Invoke-Command -ComputerName Machine1 -InDisconnectedSession -ScriptBlock {
    Start-Sleep -Seconds 500 # Some long running operation
}

# Either
Connect-PSSession -ComputerName Machine1 # Simply connects session so it can be used

# Or
Receive-PSSession -ComputerName Machine1 # Attempts to connect session and also retrieve data

# Implicit
# You can import sessions and modules from sessions. This is called implicit remoting
$s = New-PSSession -ComputerName DomainController
Import-Module -PSSession $s -Name ActiveDirectory -Prefix contoso
Get-contosoAdUser -Filter * # Cmdlet runs remotely and is used locally

# Data types, Serialization
Invoke-Command -ComputerName Machine1 -ScriptBlock {
    "hello"
} | Get-Member # Added properties PSComputerName, RunspaceId, ShowComputerName

# Complex data types are deserialized and lose their object methods
# However, all Properties still exist and usually even keep the data type
# unless it also has been deserialized
(Invoke-Command -ComputerName Machine1 -ScriptBlock {
    Get-Process
}).GetType().FullName # Deserialized.System.Diagnostics.Process