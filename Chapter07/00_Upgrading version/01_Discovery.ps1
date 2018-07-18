#http://www.adamtheautomator.com/upgrading-powershell-5-1/
Get-ADComputer -Filter "OperatingSystem -like 'Windows*'" -Properties OperatingSystem | group operatingsystem | sort name