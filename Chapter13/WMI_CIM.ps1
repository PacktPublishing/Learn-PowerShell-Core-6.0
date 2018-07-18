#Showing all the cmdlets
Get-Command -Noun CIM*

<#
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Cmdlet          Get-CimAssociatedInstance                          1.0.0.0    CimCmdlets
Cmdlet          Get-CimClass                                       1.0.0.0    CimCmdlets
Cmdlet          Get-CimInstance                                    1.0.0.0    CimCmdlets
Cmdlet          Get-CimSession                                     1.0.0.0    CimCmdlets
Cmdlet          Invoke-CimMethod                                   1.0.0.0    CimCmdlets
Cmdlet          New-CimInstance                                    1.0.0.0    CimCmdlets
Cmdlet          New-CimSession                                     1.0.0.0    CimCmdlets
Cmdlet          New-CimSessionOption                               1.0.0.0    CimCmdlets
Cmdlet          Register-CimIndicationEvent                        1.0.0.0    CimCmdlets
Cmdlet          Remove-CimInstance                                 1.0.0.0    CimCmdlets
Cmdlet          Remove-CimSession                                  1.0.0.0    CimCmdlets
Cmdlet          Set-CimInstance                                    1.0.0.0    CimCmdlets
#>

#Instance for OS
$inst = Get-CimInstance Win32_OperatingSystem

#Working with service
Get-CimInstance -ClassName win32_service -Property name, state -Fil "name = 'bits'"

#Finding Cim class
Get-CimClass -ClassName *process* -MethodName term*

#Working with session
$logon = Get-CimInstance win32_logonsession 
Get-CimAssociatedInstance $logon[0] -ResultClassName win32_useraccount

#Working with harddrive
$disk = Get-CimInstance win32_logicaldisk
Get-CimAssociatedInstance $disk[0] | Get-Member | Select-Object typename -Unique
Get-CimAssociatedInstance $disk[0] -ResultClassName win32_directory

#View associations from the logonsession and its instances
Get-CimInstance win32_logonsession | Get-CimAssociatedInstance