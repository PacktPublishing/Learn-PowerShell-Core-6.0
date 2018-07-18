#Commands WUDO
Get-Command *deliveryopt*

#Status
Get-DeliveryOptimizationStatus

#Performance Snap
Get-DeliveryOptimizationPerfSnap     

#Performance Snap for current month
Get-DeliveryOptimizationPerfSnapThisMonth

#Get WUDO log
$WUDOlog = Get-DeliveryOptimizationLog 

#Export-CSV
$WUDOlog | Export-Csv c:\temp\WUDO.log

#Show
$WUDOlog | Out-GridView

#Show Unique Values
$WUDOlog | Select-Object LevelName, Level -Unique
$WUDOlog | Select-Object "Function" -Unique

#Errors
$WUDOlog.Where{$_.Level -eq 2} | Out-GridView
$WUDOlog.Where{$_.LevelName -eq "Error"} | Out-GridView

#Grouping
$WUDOlog | Group-Object -Property Levelname 
$WUDOlog | Group-Object -Property "Function"
