#region user name and password

#Username / email address to connect to and manage Sharepoint Online
$adminUPN = "dummy@example.com"

#O365 organization name
$orgName = "examplecompany"

#retrieving user credentials
$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."

#Using the sharepoint management shell cmdlet to connect to Sharepoint by using user name and password
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $userCredential

#endregion

#region MFA
#O365 organization name
$orgName = "examplecompany"

#Using the sharepoint management shell cmdlet to connect to Sharepoint by using multifactor authentication
Connect-SPOService -Url https://$orgName-admin.sharepoint.com

#endregion


#region automated scripts

# Add this line to your profile if you always want Windows PowerShell PSModulePath
Add-WindowsPSModulePath 

#Finding the module
Get-Module -ListAvailable *online.sharepoint*

#Importing the module by name
Import-Module 'Microsoft.Online.SharePoint.PowerShell'

#Importing the module by path
Import-Module 'C:\program files\sharepoint online management shell\Microsoft.Online.SharePoint.PowerShell'

#PSModulePath
[Environment]::GetEnvironmentVariable("PSModulePath", "Machine")

#endregion

#region

#Importing the module by path
Import-Module 'C:\program files\sharepoint online management shell\Microsoft.Online.SharePoint.PowerShell'

#Username / email address to connect to and manage Sharepoint Online
$adminUPN = "dummy@example.com"

#O365 organization name
$orgName = "examplecompany"

#Retrieving password which was encrypted with a certificate and storing it as secure string
$password = Unprotect-CmsMessage -Content (Get-Content .\PasswordDDN.txt) | ConvertTo-SecureString -AsPlainText -Force 

#retrieving user credentials
$userCredential = New-Object -TypeName PSCredential $adminUPN, $password 

try {
    #Using the sharepoint management shell cmdlet to connect to Sharepoint by using user name and password
    Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $userCredential
}
catch {
    #Showing errors:
    $errorMessage = $_.Exception.Message
    $innerException = $_.Exception.InnerExceptionMessage
    Write-Error "ErrorMessage: $errorMessage" + [System.Environment]::NewLine + "InnerException: $innerException"
}

#Proving if connection was established correctly
if (-not $errorMessage) {

    #Retrieving sites
    $sites = Get-SPOSite

    #Number sites
    $sites.Count
}



#endregion