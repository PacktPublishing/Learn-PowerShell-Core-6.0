#region simple connection
#Credentials to connect to online service
$UserCredential = Get-Credential -UserName 'David@example.de' 

#Showing credentials
$UserCredential

#Don´t store passwords in file

<#
Setting up the session

For Office 365 operated by 21Vianet, use the ConnectionUri value: 
https://partner.outlook.cn/PowerShell

For Office 365 Germany, use the ConnectionUri value: 
https://outlook.office.de/powershell-liveid/

In this example we work with Office 365 Germany

#>
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

#Showing session
$Session

#Import remote functions to our current session and saving module information in variable
$returnedInformation = Import-PSSession $Session 

#Showing loaded module
$returnedInformation 

#Displaying all available cmdlets
Get-Command -Module ($returnedInformation.Name)

#Number of imported cmdlets
(Get-Command -Module ($returnedInformation.Name)).Count #684

#Showing information to Get-Mailbox 
Get-Command Get-Mailbox  | Select-Object *

#Executing
Get-Mailbox

#Invoking command remotely
Invoke-Command -Session $Session -ScriptBlock {Get-Mailbox}

#Removing session after finished
Remove-PSSession $Session

#endregion

#region secure coding

#Credentials to connect to online service
$UserCredential = Get-Credential

#Debug information
Write-Debug $UserCredential

#Set up connection
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

#Proving if the session exists
if ($Session) {    
    Write-Information 'Session established'

    #Debug information
    Write-Debug $Session

    #Clean error handling
    try {
        #Import remote functions to our current session
        $returnedInformation = Import-PSSession $Session

        #Debug ionformation
        Write-Debug $returnedInformation

        #do something
        Get-MailBox
    }
    catch {
        #Showing errors:
        $errorMessage = $_.Exception.Message
        $innerException = $_.Exception.InnerExceptionMessage
        Write-Error "ErrorMessage: $errorMessage" + [System.Environment]::NewLine + "InnerException: $innerException"
    }
    finally {
        #Removing session after error and or finished
        Remove-PSSession $Session        

        #Debug information
        Write-Debug "Session removed."
    }
}

#endregion


#region Connecting with prefix

#Defining a prefix to import exchange functions
$prefix = 'DdNExchange_'

#Import remote functions with prefix to our current session
Import-PSSession $Session -Prefix $prefix

#Displaying all available cmdlets
Get-Command "*$prefix*" -CommandType 'Function'

#Showing information to Get-Mailbox 
Get-Command ("Get-{0}Mailbox" -f $prefix) | Select-Object *

#Showing help to Get-Mailbox 
Get-Help ("Get-{0}Mailbox" -f $prefix) #Error

#Executing cmdlets
&("Get-{0}Mailbox" -f $prefix)

#endregion

#region multifactor authentication
Connect-EXOPSSession -UserPrincipalName lukas@fabrikam.com -ConnectionUri https://outlook.office.de/PowerShell-LiveID -AzureADAuthorizationEndPointUri https://login.microsoftonline.de/common

#endregion


#Gathering cmdlets and its needed management roles
$modulesWithManagementRolesNeeded = Get-Command -Module ($returnedInformation.Name) | Select-Object Name, @{Name = "ManagementRole"; Expression = {Get-ManagementRole -Cmdlet ($_.Name)}} -First 2 #just gathering the first 2 cmdlets as example

#Gathering for all unique roles the role assignee types and the role assignee names
($modulesWithManagementRolesNeeded.ManagementRole).Name | Select-Object -Unique | ForEach-Object {Get-ManagementRoleAssignment -Role $_ -Delegating $false | Format-Table -Auto Role, RoleAssigneeType, RoleAssigneeName}