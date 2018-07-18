#Importing cmdlets from SCCM on the SCCM site server
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1) 

#Setting location to site server 
Set-Location PS1

#Adding site location manually
New-PSDrive -Name [Site Code] -PSProvider "AdminUI.PS.Provider\CMSite" -Root "[FQDN of SCCM server]" -Description "SCCM Site"


