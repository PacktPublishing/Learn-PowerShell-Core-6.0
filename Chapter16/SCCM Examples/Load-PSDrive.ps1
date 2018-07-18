######################################################
##          PowerShell Community Template 1.0       ##
######################################################
<# 
.SYNOPSIS
This is a PowerShell-Script-Template for ConfigMgr-Admins
 
.DESCRIPTION
The Script will automatically load the ConfigMgr-Module and set the PS-Drive. If it is executed Remotly you will be prompt
to specify the Site-Code and SMS-Provider
 
.EXAMPLE
Run the Script with Logging and Debug-Output
./MyConfigMgrSciprt.ps1 -LogfileName XYZ -DebugMode True
 
.NOTES
You can launch your Script Debugging-Mode for CM-Cmdlets. 
We also included a little Logging-Function. You can provide it static or by the Paramter LogfileName.

.LINK
https://www.microsoft.com
#>

### Invocation Parameters

Param
(
    [Parameter(Mandatory = $false)]
    [String]$LogfileName,
    [Parameter(Mandatory = $false)]
    [ValidateSet("True")]
    [String]$DebugMode
)

### Set Debugging Options CM-CmdLets

If ($DebugMode -eq "True")
{
$Global:VerbosePreference = "Continue" 
$Global:DebugPreference = "Continue" 
$Global:CMPSDebugLogging = $true
}

### Set SCCM Parameter

[String]$SiteCode = ""
[String]$SiteProvider = ""

### Logging 

[String]$LogfileName = ""
[String]$Logfile = "$env:Temp\$LogfileName.log"

Function Write-Log
{
   Param ([string]$logstring)
   If (Test-Path $Logfile)
   {
       If ((Get-Item $Logfile).Length -gt 2MB)
       {
       Rename-Item $Logfile $Logfile".bak" -Force
       }
   }
   $WriteLine = (Get-Date).ToString() + " " + $logstring
   Add-content $Logfile -value $WriteLine
}

### Check SCCM-Console

Try
{
    $ConfigMgrModule = ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
    Import-Module $ConfigMgrModule
    Write-Host "Found SCCM-Console-Environment" -ForegroundColor Green
    Write-Host $ConfigMgrModule -ForegroundColor Green
}
Catch
{
    Write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
    Write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Console not installed or found" -ForegroundColor Red
    Write-Host "Script will exit" -ForegroundColor Red
Exit
}

### Get Site-Code and Site-Provider-Machine from WMI if possible

Try 
{
    $SMS = gwmi -Namespace 'root\sms' -query "SELECT SiteCode,Machine FROM SMS_ProviderLocation" 
    $SiteCode = $SMS.SiteCode
    $SiteProvider = $SMS.Machine
    Write-Host "SiteCode: $SiteCode" -ForegroundColor Yellow
    Write-Host "SiteServer: $SiteProvider" -ForegroundColor Yellow
}
Catch 
{
    Write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
    Write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Unable to find in WMI SMS_ProviderLocation. You have to specify them!" -ForegroundColor Red

}

### Ask for SCCM-Site-Info if the Scripts not running on the SiteServer

function Get-CustomInput([string] $title, [string] $message)
{ 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = $title
$objForm.Size = New-Object System.Drawing.Size(350,250) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$value=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(95,140)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$value=$objTextBox.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(195,140)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(30,30) 
$objLabel.Size = New-Object System.Drawing.Size(280,40) 
$objLabel.Text = $message
$objForm.Controls.Add($objLabel) 

$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Location = New-Object System.Drawing.Size(30,90) 
$objTextBox.Size = New-Object System.Drawing.Size(260,20) 
$objForm.Controls.Add($objTextBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$value = $objTextBox.Text
return $Value
}


If ([String]$SiteCode -eq "")
{
    [String]$SiteCode = Get-CustomInput "Information Needed" "Please provide the SiteCode:"
    Write-Host "The following SiteCode have been provided:" $SiteCode
}

If ([String]$SiteProvider -eq "")
{
    [String]$SiteProvider = Get-CustomInput "Information Needed" "Please provide the SiteProvider-Computer:"
    Write-Host "The following SiteProvider have been provided:" $SiteProvider
}

### Change to CM-Powershell-Drive

SL $SiteCode":"

###########################################################################
##                       End of Template Section                         ##
###########################################################################

### Your Main Code ###

