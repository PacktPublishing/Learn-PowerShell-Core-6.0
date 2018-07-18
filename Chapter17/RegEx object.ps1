[regex]$rx='Don'
$rx.Match('Don')

$rx.Match('Let me introduce David das Neves. David is a DevOps.')

$rx.Matches('Let me introduce David das Neves. David is a DevOps.')

$rx.Replace('Let me introduce David das Neves. David is a DevOps.','Dave')


$s='2012-03-14 18:57:35:321 1196 13f8 PT Server URL = http://172.116.110.1/SimpleAuthWebService/SimpleAuth.asmx'
[regex]$r='\d{2}:\d{2}:\d{2}:\d{3}'

$r.match($s)
$r.split($s)

'aaa 123 bbb 456' -match '\d{3}'
$matches

#subexpression:
'aaa 123 bbb 456' -match '(\d{3})'
$matches


'aaa 123 bbb 456' -match '(\d{3}) (\w{3})'
$matches

[regex]$rx = '(\d{3}) (\w{3})'
$m =$rx.Matches('aaa 123 bbb 456')
$m
$m.groups


'David 12356 Regex 23548' -match '(?<word>\w{5}) (?<number>\d{5})'
$matches
$matches.number
$matches.word


[regex]$rx='(?<word>\w{3}) (?<num>\d{3})'
$m = $rx.Matches('aaa 123 bbb 456')
#The tricky part is that $m contains several types of objects:
$m | foreach {$_.groups['num'].value}
$m | foreach {$_.groups['word'].value}


$p = '\\server01\data'
$p -match '^\\\\(?<server>\w+)\\(?<share>\w+$)'
$matches
$matches.server
$matches.share


#Windows Update log
$t = '2014-01-07 10:23:48:211 880 a9c IdleTmr Incremented PDC RefCount for Network to 2'

$t -match '(?<Date>\d{4}-\d{2}-\d{2})\s+(?<Time>(\d{2}:)+\d{3})\s+(?<PID>\d+)\s+(?<TID>\w+)\s+(?<Component>\w+)\s+(?<Message>.*)$'
$matches

$matches.Date
$matches.Keys | ForEach-Object { "$_"; Invoke-Expression -Command "`$matches.$_"}

[regex]$rx = '(?<Date>\d{4}-\d{2}-\d{2})\s+(?<Time>(\d{2}:)+\d{3})\s+(?<PID>\d+)\s+(?<TID>\w+)\s+(?<Component>\w+)\s+(?<Message>.*)$'
$rx.Matches($t)
$rx.GetGroupNames()
$names = $rx.GetGroupNames() | Where-Object {$_ -match '\w{2}'}

Get-WindowsUpdateLog
$path = Join-Path $env:USERPROFILE -ChildPath Desktop\WindowsUpdate.log 
$t =  Get-Content $path
$data = $t | foreach {
    $rx.Matches($_) | foreach {
        $match = $_
        $names | foreach -begin {$hash=[ordered]@{}} -process {
            $hash.Add($_,$match.groups["$_"].value)
        } -end { [pscustomobject]$hash}
    }
}
$data 

# Regexlib.com

# CBS.log
$path = 'c:\windows\logs\cbs\cbs.log'
$regexString = '(?<Date>\d{4}-\d{2}-\d{2})\s+(?<Time>(\d{2}:)+\d{2}),\s+(?<Type>\w+)\s+(?<Component>\w+)\s+(?<Message>.*)$'



$t =  Get-Content $path
[regex]$rx = $regex
$data = $t | foreach {
    $rx.Matches($_) | foreach {
        $match = $_
        $names | foreach -begin {$hash=[ordered]@{}} -process {
            $hash.Add($_,$match.groups["$_"].value)
        } -end { [pscustomobject]$hash}
    }
}
$data 

$data.Message -like '*error*'


return
$logline= '2015-12-09 18:52:38, Info                  CBS    Failed to internally open package. [HRESULT = 0x800f0805 - CBS_E_INVALID_PACKAGE]'
$rx = '(?<Line>.*)$'
$logline -match $rx
$matches

return 

$parsedLogFile = Get-RegExParsedLogfile -Path 'c:\windows\logs\cbs\cbs.log' -RegexString '(?<Date>\d{4}-\d{2}-\d{2})\s+(?<Time>(\d{2}:)+\d{2}),\s+(?<Type>\w+)\s+(?<Component>\w+)\s+(?<Message>.*)$'

$parsedLogFile.Log | Where-Object Component -eq 'CBS' | Select-Object Date, Type, Message | Format-Table -AutoSize -Wrap

$parsedLogFile = Get-RegExParsedLogfile -Path 'c:\windows\logs\cbs\cbs.log' 