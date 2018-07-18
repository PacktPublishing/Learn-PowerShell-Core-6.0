#region ObjectEvents
$eventLogQuery = @"
<QueryList>
<Query Id="0" Path="Application">
  <Select Path="Application">*[System[(EventID=1001)]]</Select>
</Query>
</QueryList>
"@

# Relies on full .NET Framework - Use Windows PowerShell
$queryObject = [System.Diagnostics.Eventing.Reader.EventLogQuery]::new('Application','LogName',$eventLogQuery)
$watcher = [System.Diagnostics.Eventing.Reader.EventLogWatcher]::new($queryObject)

# When working with object events, there are built-in variables helping you
$eventSubscription = Register-ObjectEvent -InputObject $watcher -EventName EventRecordWritten -Action {
    $eventEntry = $event.SourceEventArgs
    $eventEntry.EventRecord | Out-Host # Take a look at your event's properties
}

# Now everytime such an event is logged, the watcher will trigger and execute your script block.
$watcher.Enabled =  $true

# When done, you might want to unregister the object event
Unregister-Event -SourceIdentifier $eventSubscription.Name
#endregion

#region WMI events

$actionScript = {
    # Your previous service configuration
    $serviceBefore = $eventargs.NewEvent.PreviousInstance

    # Your modified service configuration
    $serviceAfter = if($eventargs.NewEvent.TargetInstance)
    {
        $eventargs.NewEvent.TargetInstance
    }
    else
    {
        $eventargs.NewEvent.SourceInstance
    }

    Compare-Object $serviceBefore $serviceAfter -Property Name,Description,StartMode | Out-Host
}

# No additional .NET here - we monitor for any changes of a service
# Changes are InstanceModificationEvents, while our instance is a Win32_Service
# Here we also use a SourceIdentifier as a friendly name for our event
Register-WmiEvent -Query "SELECT * FROM __instanceModificationEvent WITHIN 5 WHERE targetInstance ISA 'win32_Service'" `
-SourceIdentifier ServiceModified -Action $actionScript

# When finished
Unregister-Event -SourceIdentifier ServiceModified

# Same, but different...
Register-CimIndicationEvent -Query "SELECT * FROM CIM_InstModification WITHIN 5 WHERE targetInstance ISA 'WIN32_Service'" `
-SourceIdentifier CimServiceModified -Action $actionScript -ComputerName NODE01

# When finished
Unregister-Event -SourceIdentifier CimServiceModified
#endregion

#region EngineEvent

# In PowerShell CLI, the following engine event is triggered when closing the session
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -SupportEvent -Action {
    Write-Host -ForegroundColor Green -BackgroundColor Black "Bye $env:USERNAME"
    Start-Sleep -Seconds 3
}
#endregion

#region Remote events
Register-CimIndicationEvent -Query "SELECT * FROM CIM_InstModification WITHIN 5 WHERE targetInstance ISA 'WIN32_Service'" `
-SourceIdentifier CimServiceModified -ComputerName NODE01 -Action $actionScript

# Events created in the remote session are queued and can be
# collected at the local session
Get-Event -SourceIdentifier CimServiceModified
#endregion