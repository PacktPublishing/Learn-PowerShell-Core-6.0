
$function=@' 
[DllImport("kernel32.dll", CharSet = CharSet.Auto,SetLastError = true)]
  public static extern void SetThreadExecutionState(uint esFlags);
'@

$method = Add-Type -MemberDefinition $function -name System -namespace Win32 -passThru 
$ES_CONTINUOUS = [uint32]'0x80000000'
$ES_AWAYMODE_REQUIRED = [uint32]'0x00000040'
$ES_DISPLAY_REQUIRED = [uint32]'0x00000002'
$ES_SYSTEM_REQUIRED = [uint32]'0x00000001'

#Configuring the system to ignore any energy saving technologies
$method::SetThreadExecutionState($ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED -bor $ES_CONTINUOUS)

#Executing an installation e.g. 
& msiexec.exe /i \\Share\ImportantInstallation.msi /qb 

#Restoring saving mechanisms
$method::SetThreadExecutionState($ES_CONTINUOUS)
