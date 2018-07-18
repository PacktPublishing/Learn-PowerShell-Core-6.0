#$Eventfolder = Get-Winevent -ListLog *


($Eventfolder.Logname).Replace('/','_')


foreach ( $eventname in (($Eventfolder.Logname).Replace('/','_')))
{
   Write-Host Get-WinEvent -LogName $eventname | Export-Clixml c:\temp\$($eventname).xml

}
