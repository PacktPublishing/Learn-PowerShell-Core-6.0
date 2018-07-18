#Example - creating SCCM package via PowerShell
$packageInformation = @{
    $Name='Test Package'
    $Description='This is an example scription'
    $Manufacturer='Manufacturer'
    $Version = '1.0'
    $Path ='\\server\shared\TestPackage1'
}

#Create new package with values
New-CMPackage @packageInformation
