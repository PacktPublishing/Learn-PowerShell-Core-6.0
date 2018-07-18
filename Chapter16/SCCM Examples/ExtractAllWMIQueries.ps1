<#   
    .NOTES
    ===========================================================================
     Created on:    3/30/2017 
     Created by:    Timmy Andersson
     Contact:   @Timmyitdotcom
    ===========================================================================
    .DESCRIPTION
        Extracts all the WMI-queries used in SCCM and outputs them in to a .txt files for each Device Collection. 
#>
[CmdletBinding(DefaultParameterSetName = 'DestinationPath')]
param
(
    [Parameter(Mandatory = $true,
               Position = 1)]
    $DestinationPath
)
 
BEGIN
{
    [String]$Filepath = $DestinationPath
     
    $SiteCodeObjs = Get-WmiObject -Namespace "root\SMS" -Class SMS_ProviderLocation -ComputerName $env:COMPUTERNAME -ErrorAction Stop
    foreach ($SiteCodeObj in $SiteCodeObjs)
    {
        if ($SiteCodeObj.ProviderForLocalSite -eq $true)
        {
            $SiteCode = $SiteCodeObj.SiteCode
        }
    }
    $SitePath = $SiteCode + ":"
     
    Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
     
}
PROCESS
{
    if (-not (Test-Path $DestinationPath))
    {
        new-item -Path $DestinationPath -ItemType Directory -Force
    }
     
    Set-location $SitePath
     
    $AllDC = (Get-CMDeviceCollection).Name
    Foreach ($Devicecollection in $AllDc)
    {
        $CollectionMR = Get-CMDeviceCollectionQueryMembershipRule -CollectionName "$Devicecollection"
        if ($CollectionMR -ne $null)
        {
            $Query = $CollectionMR.QueryExpression
            Out-File -FilePath "$DestinationPath$($Devicecollection).txt" -InputObject $Query
        }
         
    }
}
END
{
}