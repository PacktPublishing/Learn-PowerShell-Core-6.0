function New-ForensicPSWMIEventSubScription
{
  <#
    .SYNOPSIS
    Create an event subscription to catch suspicious PowerShell executions.
    .DESCRIPTION
    Create an event subscription to catch suspicious PowerShell executions.
    Catches unusual PowerShell hosts and unusual loaded System.Management.Automation.dll files.
    
    Derivated from the example - BlueHat 2016 - WMI attack detection demo by Matt Graeber
    https://gist.github.com/mattifestation/fa2e3cea76f70b1e2267
    .EXAMPLE
    New-ForensicPSWMIEventSubScription
    Use the default settings
    .EXAMPLE
    New-ForensicPSWMIEventSubScription
    Write your own settings
  #>
  [CmdletBinding()]
  param
  (
    #locally used naming variable
    [Parameter(Mandatory=$false, Position=0)]
    [System.String]
    $SourceIdentifier = 'WMIEventHandler_PowerShellHostProcessStarted',
    
    #Define whitelisted host processes
    [Parameter(Mandatory=$false, Position=1)]
    [System.String[]]
    $WhitelistedProcesses = @('powershell_ise.exe','powershell.exe'),
    
    #Define whitelisted dll substrings
    [Parameter(Mandatory=$false, Position=2)]
    [System.String[]]
    $WhitelistedDllSubStrings = @('NativeImages_v4.0.30319_','GAC_MSIL\System.Management.Automation\v4.0')
  )  
  
  #The following scriptBlock is being executed, if the trigger is being fired
  $PSHostProcessStarted = {
    $Event = $EventArgs.NewEvent
    
    $LoadTime = [DateTime]::FromFileTime($Event.TIME_CREATED)
    $ProcessID = $Event.ProcessID
    
    #Important: The process may already be exited
    #It can possibly retrieve further information for the process
    $ProcInfo = Get-WmiObject -Query "SELECT * FROM Win32_Process WHERE ProcessId=$PID" -ErrorAction SilentlyContinue
    
    #Store process information
    $CommandLine = $ProcInfo.CommandLine
    $ProcessName = $ProcInfo.Name
    
    #validate if process name is whitelisted
    if ($ProcessName -in $WhitelistedProcesses) {
      $stateUsedHost = 'good'
    }
    else {
      $stateUsedHost = 'bad'
      Write-EventLog -LogName "Windows PowerShell" -Source 'PowerShell' -EventID 1337 -EntryType Warning -Message 'An untypical PowerShell host has been used to execute PowerShell code.' -Category 1
    }
    
    #validate if dll name is whitelisted
    $stateUsedDLL = 'bad'
    $fileNameDLL = $($Event.FileName)
    foreach ($substring in $WhitelistedDllSubStrings)
    {
      if ($fileNameDLL -like "*$subString*")
      {
        $stateUsedDLL = 'good'
        #after the first occurence has been found, further looping becomes unnecessary
        break
      }
    }
    if ($stateUsedDLL -eq 'bad')
    {
      Write-EventLog -LogName "Windows PowerShell" -Source 'PowerShell' -EventID 1338 -EntryType Warning -Message 'An untypical Automation dll has been used to execute PowerShell code.' -Category 1
    }
    
    #Visualize 
    $furtherInformation = @"
SIGNATURE: Host PowerShell process started

Date/Time: $LoadTime
Process ID: $ProcessID
Process Name: $ProcessName
Command Line: $CommandLine
StateUsedHost: $stateUsedHost
StateUsedDll: $stateUsedDll
Dll loaded: $fileNameDLL
"@
    
    Write-Warning $furtherInformation 
    
    #write log entry with full information, if dll or host was unknown
    if (($stateUsedDLL -eq 'bad') -or ($stateUsedHost -eq 'bad'))
    {
      Write-EventLog -LogName "Windows PowerShell" -Source 'PowerShell' -EventID 1339 -EntryType Information -Message $furtherInformation -Category 1
      
      #Writing additional information for forensics
      $EventArgs | Export-Clixml -Path C:\temp\EventArgs.clixml
      $ProcInfo | Export-Clixml -Path C:\temp\ProcInfo.clixml
      #If you want to store all information added date to file
      #$ProcInfo | Export-Clixml -Path ("c:\temp\ProcInfo_{0}.clixml" -f $(get-date -f yyyyMMdd_hhmmss))
      #$EventArgs | Export-Clixml -Path ("c:\temp\EventArgs_{0}.clixml" -f $(get-date -f yyyyMMdd_hhmmss))
    }
  }
  
  # The following trigger is defined by its query on the Win32_ModuleLoadTrace class.
  # Every time the dll is being loaded from a script, the action $PSHostProcessStarted is started.
  $PSHostProcArgs = @{
    Query = 'SELECT * FROM Win32_ModuleLoadTrace WHERE FileName LIKE "%System.Management.Automation%.dll%"'
    Action = $PSHostProcessStarted
    SourceIdentifier = $sourceIdentifier
  }
  
  
  #Register alert for current session
  Register-WmiEvent @PSHostProcArgs
}

#Create new subscription
New-ForensicPSWMIEventSubScription -SourceIdentifier 'PS_ES' -WhitelistedProcesses @('PowerShell.exe') -WhitelistedDllSubStrings ('NativeImages_v4.0.30319_')

#Remove event
Unregister-Event -SourceIdentifier 'PS_ES'


#region loading additional information

$ProcInfo = import-Clixml c:\temp\ProcInfo.clixml
$EventArgs = import-Clixml c:\temp\EventArgs.clixml

Get-ChildItem -Path c:\temp\ -Filter *.clixml

#endregion

