

#Retrieves file hash for ISE with SHA256 algorithm
Get-FileHash $PSHOME\PowerShell_ISE.exe | Format-List

#Retrieves file hash for ISE with SHA384 algorithm
Get-FileHash $PSHOME\PowerShell_ISE.exe -Algorithm SHA384 | Format-List




#Compute the hash value of a stream and compare the procedure with getting the hash from the file directly
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash

#Path of Microsoft.PowerShell.Utility.psd1
$file = (Get-Module Microsoft.PowerShell.Utility).Path

$hashFromFile = Get-FileHash -Path $file -Algorithm MD5

#Open $file as a stream
$stream = [System.IO.File]::OpenRead($file)
$hashFromStream = Get-FileHash -InputStream $stream -Algorithm MD5
$stream.Close()

Write-Host '### Hash from File ###' -NoNewline
$hashFromFile | Format-List
Write-Host '### Hash from Stream ###' -NoNewline
$hashFromStream | Format-List

#Check both hashes are the same
if ($hashFromFile.Hash -eq $hashFromStream.Hash) {
	Write-Host 'Get-FileHash results are consistent' -ForegroundColor Green
} else {
	Write-Host 'Get-FileHash results are inconsistent!!' -ForegroundColor Red
}
