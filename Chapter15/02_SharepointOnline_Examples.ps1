Import-Module Microsoft.Online.SharePoint.Powershell

#Retrieving lists in a site collection:

Get-SPSite http://spexample/sites/training -Limit All |
   Select -ExpandProperty AllWebs |
   Select -ExpandProperty Lists |
   Select ParentWebUrl, Title

#Retrieving sites in a single web application:

Get-SPSite -WebApplication http://spexample -Limit All |
   Select -ExpandProperty AllWebs |
   Select -ExpandProperty Lists |
   Select ParentWebUrl, Title

All site collections in the farm:

Get-SPSite -Limit All |
   Select -ExpandProperty AllWebs |
   Select -ExpandProperty Lists |
   Select {$_.ParentWeb.Url}, Title

#Retrieve 5 biggest sharepoint sites
Get-SPOSite -Limit All |
Select-Object @{Label = "Site Name"; Expression = {$_.url}},
@{N = 'SizeRaw'; E = {$_.usage.storage}},
@{N = "Size in MB"; E = {'{0:N2} MB' -f ($_.usage.storage / 1MB)}} |
Sort-Object -Descending -Property SizeRaw |
Select-Object -first 5


#Finding List Items and Library Documents of a Certain Type
