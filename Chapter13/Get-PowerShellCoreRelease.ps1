#Retrieves the latest PowerShell Core version - mainly built for Windows OS.
Function Get-LatestPowerShellVersion {  
    #Using TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    #Retrieving the latest PowerShell versions as JSON
    $JSON = Invoke-WebRequest "https://api.github.com/repos/powershell/powershell/releases/latest"| ConvertFrom-Json

    #Validating if PowerShell Core 6 is being used
    If ($PSVersionTable.GitCommitId) {
        If ($JSON.tag_name -ne $PSVersionTable.GitCommitId) {
            Write-Host "New version of PowerShell available: $($JSON.Name)"
                        
            $osarch = "x64"
            #Validating if architecture of OS is 64 bits
            if (-not [System.Environment]::Is64BitOperatingSystem) {
                $osarch = "x86"
            }

            Write-Host "The architecture of Windows is $($osarch)."

            #Download string for MSI            
            $urlToMSI = ($JSON.assets.browser_download_url).Where{$_ -like "*-win-$osarch.msi"} | Select-Object -First 1
           
            #Download to desktop - creating download path
            $downloadPath = Join-Path -Path $([System.Environment]::GetFolderPath("DesktopDirectory")) -ChildPath ([System.IO.Path]::GetFileName($urlToMSI))

            if ($downloadPath) {
                Write-Host "File already download."    
            }
            else {
                Write-Host "Downloading file $urlToMSI to Desktop."

                #Downloading file
                $client = New-Object System.Net.WebClient
                $client.DownloadFile($urlToMSI, $downloadPath)           
                
                Write-Host "Download completed."             
            }           

            return $downloadPath
        } 
        Else {
            "PowerShell is currently up to date!"
        }
    }
    else {
        Write-Host "No GitCommitId could be found, because you are using PowerShell Version $($PSVersionTable.PSVersion)"
    }
}
 
#validating, if a new version exist and download it
#the downloaded file path will be returned
$downloadPath = Get-LatestPowerShellVersion 

#Execute MSI
Start-Process $downloadPath