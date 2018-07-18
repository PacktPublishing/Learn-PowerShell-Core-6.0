Connect-RsReportServer -ComputerName "sql2017" -ReportServerInstance "MSSQLSERVER"

Connect-RsReportServer -ReportServerUri "http://sql2017/reportserver/"

New-RsWebServiceProxy -ReportServerUri "http://sql2017/reportserver/"

Connect-RsReportServer -ReportPortalUri 'http://sql2017/reports'

Get-RsFolderContent -RsFolder "/" -Recurse

#region Exporting content

# Export /Foo/Example to the current path
Out-RsCatalogItem -RsItem /Foo/Example -Destination .

# Export all Data Sources in /Foo
Get-RsFolderContent -RsFolder "/Foo" |
    Where-Object TypeName -eq DataSource |
        Select-Object -ExpandProperty Path |
            Out-RsCatalogItem -Destination .

# Export all items that were created in the last 7 days
Get-RsFolderContent -RsFolder "/" -Recurse |
    Where-Object { ($_.CreationDate -gt (Get-Date).AddDays(-7)) -and ($_.TypeName -ne "Folder") } |
        Select-Object -ExpandProperty Path |
            Out-RsCatalogItem -Destination .

# Export all content in the SSRS data store
Out-RsFolderContent -RsFolder "/" -Recurse -Destination .

#endregion

#region importing content

# Import Example.rsds into the SSRS folder /Foo
Write-RsCatalogItem -Path .\Example.rsds -RsFolder "/Foo"
 
# Import all reports in the current folder
Get-ChildItem *.rdl |
    Select-Object -ExpandProperty FullName |
        Write-RsCatalogItem -RsFolder "/Foo"

# Import everything in C:\Import and subfolders
Write-RsFolderContent -Path C:\Import -RsFolder "/" -Recurse

#endregion

#region Configuring SSRS Servers

# Setting up localhost
$paramSetRsDatabase = @{
    DatabaseServerName = 'localhost'
    Name = 'ReportServer'
    DatabaseCredentialType = 'ServiceAccount'
}
Set-RsDatabase @paramSetRsDatabase
 
# Connecting to an existing database with custom credentials
$paramSetRsDatabase = @{
    DatabaseServerName = 'sql2017'
    Name = 'ExistingReportServer'
    IsExistingDatabase = $true
    DatabaseCredentialType = 'Windows'
    DatabaseCredential = $myCredentials
}
Set-RsDatabase @paramSetRsDatabase

##

# Set up with default paths
Set-RsUrlReservation
 
# Set up with special names and ports
$paramSetRsUrlReservation = @{
    ReportServerVirtualDirectory = 'ReportServer2017'
    PortalVirtualDirectory = 'Reports2017'
    ListeningPort = 8080
}
Set-RsUrlReservation @paramSetRsUrlReservation

Initialize-Rs

#endregion