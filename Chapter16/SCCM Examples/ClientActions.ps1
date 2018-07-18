param ( [string] $action = "") 

function executeSCCMAction ([string]$srv, [string]$action, $fscheduleID){

   #Binding SMS_Client wmi class remotely.... 
   $SMSCli = [wmiclass] "\\$srv\root\ccm:SMS_Client"

   if($SMSCli){
      if($action -imatch "full"){
         #Clearing HW or SW inventory delta flag...
         $wmiQuery = "\\$srv\root\ccm\invagt:InventoryActionStatus.InventoryActionID=$fscheduleID"
         $checkdelete = ([wmi]$wmiQuery).Delete()
      }   
      #Invoking $action ...
      Write-Host "$srv, Invoking action $script:actionName"
      $check = $SMSCli.TriggerSchedule($fscheduleID)
   }
   else{
      # could not get SCCM WMI Class
      Write-Host "$srv, could not get SCCM WMI Class"
   }
}

switch ($action) {
   "hw" {
      $scheduleID = "{00000000-0000-0000-0000-000000000001}"
      $script:actionName = "Hardware Inventory Cycle (Delta)"
   }
   "hwfull" {
      $scheduleID = "{00000000-0000-0000-0000-000000000001}"
      $script:actionName = "Hardware Inventory Cycle (Full)"
   }
   "sw" {
      $scheduleID = "{00000000-0000-0000-0000-000000000002}"
      $script:actionName = "Software Inventory Cycle (Delta)"
   }
   "swfull" {
      $scheduleID = "{00000000-0000-0000-0000-000000000002}"
      $script:actionName = "Software Inventory Cycle (Full)"
   }
   "datadisc" {
      $scheduleID = "{00000000-0000-0000-0000-000000000003}"
      $script:actionName = "Discovery Data Collection Cycle (Delta)"
   }
   "datadiscfull" {
      $scheduleID = "{00000000-0000-0000-0000-000000000003}"
      $script:actionName = "Discovery Data Collection Cycle (Full)"
   }
   "filecollect" {
      $scheduleID = "{00000000-0000-0000-0000-000000000010}"
      $script:actionName = "File Collection Cycle (Delta)"
   }
   "filecollectfull" {
      $scheduleID = "{00000000-0000-0000-0000-000000000010}"
      $script:actionName = "File Collection Cycle (Full)"
   } 
   "swupdatedeploy" {
      $scheduleID = "{00000000-0000-0000-0000-000000000108}"
      $script:actionName = "Software Updates Deployment Evaluation Cycle"
   }
   "swupdatescan" {
      $scheduleID = "{00000000-0000-0000-0000-000000000113}"
      $script:actionName = "Software Updates Scan Cycle"
   }
   default {
      Write-Host -ForegroundColor 'red' "No valid Action is specified. Exiting..."
      exit
   }
}

#getting hostlist from pipe i.e.: PS C:\> gc list.txt | script.ps1
$hostlist = @($Input)

if($($hostlist.length) -gt 0){
   foreach ($srv in $hostlist) {
      if($srv){
         executeSCCMAction $srv $action $scheduleID 
      }
   }
}
else{
   # No hostname or hostlist is specified
}