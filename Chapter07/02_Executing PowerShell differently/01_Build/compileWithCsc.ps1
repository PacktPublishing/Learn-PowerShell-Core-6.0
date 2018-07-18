#region Windows 10 x64

#Global Assembly Cache
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /r:C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:"C:\temp\prog.exe" "C:\temp\prog.cs"

#Native dll
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /r:C:\Windows\Microsoft.NET\assembly\GAC_MSIL\System.Management.Automation\v4.0_3.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:"C:\temp\prog.exe" "C:\temp\prog.cs"

#endregion





#region Windows 7 x64
C:\Windows\Microsoft.NET\Framework64\v2.0.50727\csc.exe /r:C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:"C:\temp\prog.exe" "C:\temp\prog.cs"
#endregion

#region Windows 7 x86
C:\Windows\Microsoft.NET\Framework\v2.0.50727\csc.exe /r:C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:"C:\temp\prog.exe" "C:\temp\prog.cs"
#endregion

#region Windows 10 x86
C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe /r:C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:"C:\temp\prog.exe" "C:\temp\prog.cs"
#endregion


