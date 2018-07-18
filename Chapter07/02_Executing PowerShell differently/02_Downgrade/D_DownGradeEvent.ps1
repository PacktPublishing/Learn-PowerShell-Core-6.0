#The event ID 400 provides lifecycle events
#The following query retrieves initiated session, which has been started with an Engine version lower than
#This would catch typical downgrade attacks
Get-WinEvent -LogName "Windows PowerShell" |
    Where-Object Id -eq 400 |
    Foreach-Object {
        $version = [Version] ($_.Message -replace '(?s).*EngineVersion=([\d\.]+)*.*','$1')
        if($version -lt ([Version] "5.0")) { $_ }
}

#Proving if the current process is executed as 64bit
[System.Environment]::Is64BitProcess