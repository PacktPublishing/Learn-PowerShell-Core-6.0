#Reading content of log file - last 50 lines
$targetData = Get-Content C:\Windows\Logs\DISM\dism.log -Tail 50

#2 example lines of code - replaced pattern values with {%Name%:%Value%}
$TemplateContent = @'
{Date*:2015-12-15} {Time:21:04:26}, {Level:Info}                  {Component:DISM}   API: PID={PID:1472} TID={TID:5760} {Info:DismApi.dll:                                            - DismInitializeInternal}
{Date*:2015-12-15} {Time:21:04:26}, {Level:Info}                  {Component:DISM}   API: PID={PID:1472} TID={TID:5760} {Info:DismApi.dll: <----- Starting DismApi.dll session -----> - DismInitializeInternal}
'@

#Parse File
$parsedFile = $targetData | ConvertFrom-String -TemplateContent $TemplateContent 

#Show parsed data
$parsedFile | Select-Object -First 50 |  Format-Table -AutoSize -Wrap