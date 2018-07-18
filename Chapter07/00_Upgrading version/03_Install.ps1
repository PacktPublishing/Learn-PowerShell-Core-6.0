#http://www.adamtheautomator.com/upgrading-powershell-5-1/

#Or over SCCM e.g.

Set oShell = WScript.CreateObject("WScript.Shell")
Set oFso = CreateObject("Scripting.FileSystemObject")

strWorkingDir = oFso.GetParentFolderName(wscript.ScriptFullName)
'Change this to whatever file name it is
psInstallerPath = strWorkingDir &amp; "\Windows6.1-KB2819745-x86-MultiPkg.msu

Set swbemLocator = CreateObject("WbemScripting.SWbemLocator")
Set swbemServices = swbemLocator.ConnectServer(".", "Root\CIMV2")

if oFSO.GetFileVersion("c:\windows\system32\windowsPowerShell\v1.0\PowerShell.exe") = "6.0.6002.18111" then
    Set colArchs = swbemServices.ExecQuery("SELECT SystemType FROM Win32_ComputerSystem",,48)
    For Each objArch in colArchs
        If InStr(objArch.SystemType,"x64-based PC") &gt; 0 Then
            oShell.Run "wusa.exe " &amp; psInstallerPath &amp; " /quiet /norestart",0,True
        Else
            Wscript.Quit(10)
        End If
    Next
end if


Set oShell = WScript.CreateObject("WScript.Shell")
Set oFso = CreateObject("Scripting.FileSystemObject")
 
strWorkingDir = oFso.GetParentFolderName(wscript.ScriptFullName)
'Change this to whatever file name it is
psInstallerPath = strWorkingDir &amp; "\Windows6.1-KB2819745-x86-MultiPkg.msu
 
Set swbemLocator = CreateObject("WbemScripting.SWbemLocator")
Set swbemServices = swbemLocator.ConnectServer(".", "Root\CIMV2")
 
if oFSO.GetFileVersion("c:\windows\system32\windowsPowerShell\v1.0\PowerShell.exe") = "6.0.6002.18111" then
    Set colArchs = swbemServices.ExecQuery("SELECT SystemType FROM Win32_ComputerSystem",,48)
    For Each objArch in colArchs
        If InStr(objArch.SystemType,"x64-based PC") &gt; 0 Then
            oShell.Run "wusa.exe " &amp; psInstallerPath &amp; " /quiet /norestart",0,True
        Else
            Wscript.Quit(10)
        End If
    Next
end if


## Again, doesn't have to be AD
$computers = Get-AdComputer -Filter *
 
foreach ($Computer in $Computers) {
    if (Test-Connection -Computername $Computer -Quiet -Count 1) {
        $folderPath = 'C:\PowerShellDeployment'
        Copy-Item -Path $folderPath -Destination "\\$Computer\c$"
        psexec \\$Computer cscript "$folderPath\installPs.vbs"
        Remove-Item "\\$Computer\c$\PowerShellDeployment" -Recurse -Force
        Restart-Computer -Computername $Computer -Force
}