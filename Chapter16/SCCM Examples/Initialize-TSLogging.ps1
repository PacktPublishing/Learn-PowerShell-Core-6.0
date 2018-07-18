<#
.Synopsis
   Loads the module and fills the data for logging.
.DESCRIPTION
    Loads the module and fills the data for logging.
   Should be placed in the init block.
.EXAMPLE
   Initialize-TSLogging
#>
function Initialize-TSLogging
{
    # Construct TSEnvironment object
    try 
    {
        $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
    }
    catch
    {
        Write-Error -Message 'Unable to construct Microsoft.SMS.TSEnvironment Object' 
        Start-Sleep -Seconds 1
        exit 1
    }
    
    #gets the parent calling function to retrieve the executing function
    #for example: Set-NetConfig uses this script - the logfile will be Set-NetConfig.log
    $Filename =  (Get-PSCallStack)[1].Command -replace "ps1","log"
 
    # Determine log file location
    $LogFilePath = Join-Path -Path $Script:TSEnvironment.Value('_SMSTSLogPath') -ChildPath $Filename

    Write-Information -MessageData "Logfile: $LogFilePath"

    return $LogFilePath
}
