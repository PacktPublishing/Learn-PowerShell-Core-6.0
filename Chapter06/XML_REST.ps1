#Retrieving the RSS feed from the MSDN PowerShell blogs
Invoke-RestMethod -Uri https://blogs.msdn.microsoft.com/powershell/feed/ | Select-Object Title, Link, PubDate | Out-GridView