#region Get-EventLog

#Retrieve the log files
Get-EventLog -List

#Retrieving last 10 entries for System
Get-Eventlog -LogName System -Newest 10

#Retrieving last 20 entries for System with the EntryType "Error"
Get-EventLog -LogName System -EntryType Error -Newest 20

#Retrieving from a defined log "Windows PowerShell" all entries which contain "failed"
Get-EventLog -LogName "Windows PowerShell" -Message "*failed*"

#Filtering on date
Get-EventLog -Log "System" -EntryType Error -After (Get-Date 10.06.2018) -Before (Get-Date 01.07.2018) -Newest 20

#Filtering
Get-EventLog System -Newest 500 | Where-Object {$_.EventID -eq "1074" -or $_.EventID -eq "6008" -or $_.EventID -eq "1076"} | Select-Object -First 5| Format-Table Machinename, TimeWritten, UserName, EventID, Message -AutoSize -Wrap

#endregion


#region Get-WinEvent
#Retrieve all the log files       
Get-WinEvent -ListProvider * | Format-Table            
            
#List all event providers for PowerShell.           
Get-WinEvent -ListProvider *PowerShell* | Format-Table            
            
#List the logs for PowerShell           
Get-WinEvent -ListLog *PowerShell*            
            
#List all possible event IDs and descriptions for Microsoft-Windows-PowerShell           
(Get-WinEvent -ListProvider Microsoft-Windows-PowerShell ).Events |            
   Format-Table id, description -AutoSize            
            
#List all of the event log entries for operational PowerShell information          
Get-WinEvent -LogName  Microsoft-Windows-PowerShell/Operational        
            
#Retrieve the provider with the information for event if for module logging       
(Get-WinEvent -ListProvider  Microsoft-Windows-PowerShell).Events | Where-Object {$_.Id -eq 4103}
                        
#Find an event ID across all ETW providers:            
Get-WinEvent -ListProvider * |            
   ForEach-Object { $_.Events | Where-Object {$_.ID -eq 4103} }    
   
#Retrieving warning entries for PowerShell from the last 24 hours
Get-WinEvent -FilterHashTable @{LogName='Windows PowerShell'; Level=3; StartTime=(Get-Date).AddDays(-1)}

#Find all application errors from the last 7 days
Get-WinEvent -FilterHashtable @{Logname="Application"; ProviderName="Application Error"; Data="outlook.exe"; StartTime=(Get-Date).AddDays(-7)}

#Working with the FilterHashTable 
#Retrieving the last 10 successfully applied updates
$filter = @{ ProviderName="Microsoft-Windows-WindowsUpdateClient"; Id=19 }
Get-WinEvent -FilterHashtable $filter | Select-Object -ExpandProperty Message -First 10

#Working with FilterHashTable and converting the properties to an aray
$filter = @{ ProviderName="Microsoft-Windows-WindowsUpdateClient"; Id=19 }
Get-WinEvent -FilterHashtable $filter |  
  ForEach-Object {
    # ReplacementStrings array    
    $ReplacementStrings = $_.Properties | ForEach-Object { $_.Value }
    
    #Creating PSCustomObjects with the array information
    [PSCustomObject]@{
      Time = $_.TimeCreated
      Name = $ReplacementStrings[0] # the first index contains the name
      User = $_.UserId.Value
    }
  }

#endregion
