Get-ChildItem -Recurse

SQLSERVER:

SQLSERVER:\SQL\<computername>\<instancename>

Set-Location SQLSERVER:\SQL\SQL2017\Default

Get-ChildItem SQLSERVER:\SQL\SQL2017\Default\Databases\master\Tables\dbo.allcountries\columns | Format-Table Name, DataType, Collation, Computed, State

$server = Get-SqlInstance -ServerInstance sql2017

$server | Get-SqlAgent

Invoke-Sqlcmd -ServerInstance "sql2017" -Query "SELECT 1 AS Value;"

$primaryServer = Get-SqlInstance -MachineName PrimaryComputer -Name Instance
$secondaryServer = Get-SqlInstance -MachineName SecondaryComputer -Name Instance

##

# Backup database and log from primary server
$paramBackupSqlDatabase = @{
    Database     = "Database1"
    BackupFile   = \\fileserver\backups\Database1.bak
    InputObject  = $primaryServer
}
Backup-SqlDatabase @paramBackupSqlDatabase

$paramBackupSqlDatabase = @{
    Database     = "Database1"
    BackupFile   = \\fileserver\backups\Database1.log
    InputObject  = $secondaryServer
    BackupAction = 'Log'
}

Backup-SqlDatabase @paramBackupSqlDatabase

# Restore the database and log on the secondary (using NO RECOVERY)  
$paramRestoreSqlDatabase = @{
    Database     = "Database1"
    BackupFile   = \\fileserver\backups\Database1.bak
    InputObject  = $secondaryServer
    NoRecovery   = $true
}
Restore-SqlDatabase @paramRestoreSqlDatabase

$paramRestoreSqlDatabase = @{
    Database      = "Database1"
    BackupFile    = \\fileserver\backups\Database1.log
    InputObject   = $secondaryServer
    RestoreAction = 'Log'
    NoRecovery    = $true
}
Restore-SqlDatabase @paramRestoreSqlDatabase

##

# Create an in-memory representation of the primary replica.
$paramNewSqlAvailabilityReplica = @{
    Name              = "PrimaryComputer\Instance"
    EndpointUrl       = "TCP://PrimaryComputer.domain.com:5022"
    AvailabilityMode  = "SynchronousCommit"
    FailoverMode      = "Automatic"
    Version           = 12
    AsTemplate        = $true
}
$primaryReplica = New-SqlAvailabilityReplica @paramNewSqlAvailabilityReplica
 
# Create an in-memory representation of the secondary replica.  
$paramNewSqlAvailabilityReplica = @{
    Name              = "SecondaryComputer\Instance"
    EndpointUrl       = "TCP://SecondaryComputer.domain.com:5022"
    AvailabilityMode  = "SynchronousCommit"
    FailoverMode      = "Automatic"
    Version           = 12
    AsTemplate        = $true
}
$secondaryReplica = New-SqlAvailabilityReplica @paramNewSqlAvailabilityReplica

##

# Create the availability group
$paramNewSqlAvailabilityGroup = @{
    Name                 = "AvailabilityGroup1"
    InputObject          = $primaryServer
    AvailabilityReplica  = @($primaryReplica, $secondaryReplica)
    Database             = "Database1"
}
New-SqlAvailabilityGroup @paramNewSqlAvailabilityGroup

# Join the secondary replica to the availability group. 
$paramJoinSqlAvailabilityGroup = @{
    InputObject  = $secondaryServer
    Name         = "AvailabilityGroup1"
}
Join-SqlAvailabilityGroup @paramJoinSqlAvailabilityGroup

# Join the secondary database to the availability group.
$paramAddSqlAvailabilityDatabase = @{
    Path      = "SQLSERVER:\SQL\SecondaryComputer\Instance\AvailabilityGroups\AvailabilityGroup1"
    Database  = "Database1"
}
Add-SqlAvailabilityDatabase @paramAddSqlAvailabilityDatabase

$server =  Get-SqlInstance -ServerInstance sql2017

# Check on credential
$server | Get-SqlCredential -Name "AD\ser_SqlPowerShell" | fl *

# Update Credential
$cred = Get-Credential
$server | Set-SqlCredential -Name "AD\ser_SqlPowerShell" -Secret $cred.Password

##

$paramNewSelfSignedCertificate = @{
    Subject            = "AlwaysEncryptedCert"
    CertStoreLocation  = 'Cert:CurrentUser\My'
    KeyExportPolicy    = 'Exportable'
    Type               = 'DocumentEncryptionCert'
    KeyUsage           = 'DataEncipherment'
    KeySpec            = 'KeyExchange'
}
$cert = New-SelfSignedCertificate @paramNewSelfSignedCertificate

##

$database = $server | Get-SqlDatabase databasename

##

$paramNewSqlCertificateStoreColumnMasterKeySettings = @{
    CertificateStoreLocation  = "CurrentUser"
    Thumbprint                = $cert.Thumbprint
}
$cmkSettings = New-SqlCertificateStoreColumnMasterKeySettings @paramNewSqlCertificateStoreColumnMasterKeySettings
 
$paramNewSqlColumnMasterKey = @{
    Name                     = "ColumnMasterKey1"
    InputObject              = $database
    ColumnMasterKeySettings  = $cmkSettings
}
New-SqlColumnMasterKey @paramNewSqlColumnMasterKey

$paramNewSqlColumnEncryptionKey = @{
    Name                 = "ColumnEncryptionKey1"
    InputObject          = $database
    ColumnMasterKeyName  = " ColumnMasterKey1"
}
New-SqlColumnEncryptionKey @paramNewSqlColumnEncryptionKey

##


