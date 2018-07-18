Find-Module dbatools

Install-Module dbatools

Find-DbaInstance -DiscoveryType Domain,DataSourceEnumeration

Find-DbaInstance -DiscoveryType All

Get-ADComputer -Filter "*" | Find-DbaInstance

$server = Connect-DbaInstance -SqlInstance sql2017 -Database db1 -ConnectTimeout 45 -LockTimeout 30 -NetworkProtocol TcpIp -StatementTimeout 15

# Plain Query
Invoke-DbaSqlQuery -SqlInstance server\instance -Query 'SELECT foo FROM bar'

# From File
Invoke-DbaSqlQuery -SqlInstance server\instance -File .\rebuild.sql

Get-ChildItem | Write-DbaDataTable -SqlInstance sql2017 -Table mydb.dbo.logs -Truncate

Find-DbaCommand -Tag copy

Find-DbaCommand -Pattern snapshot

Find-DbaCommand -Author chrissy

##

# Backup the databases selected
Backup-DbaDatabase -SqlInstance Server1 -Database HR, Finance

# Restore databases
Restore-DbaDatabase -SqlInstance server1\instance1 -Path \\server2\backups

# List backup history
Get-DbaBackupHistory -SqlInstance server1

# Measure backup throughput
Measure-DbaBackupThroughput -SqlInstance server1

##

Test-DbaLastBackup -SqlInstance server1

##

Get-DbaRegisteredServer -SqlInstance cms | Install-DbaFirstResponderKit
Get-DbaRegisteredServer -SqlInstance cms | Install-DbaMaintenanceSolution
Get-DbaRegisteredServer -SqlInstance cms | Install-DbaWhoIsActive

##

Copy-DbaLogin -Source sql2000 -Destination sql2017

Start-DbaMigration -Source sqlserver\instance -Destination sqlcluster -DetachAttach


