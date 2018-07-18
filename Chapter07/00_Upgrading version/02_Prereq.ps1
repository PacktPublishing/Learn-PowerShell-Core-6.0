#http://www.adamtheautomator.com/upgrading-powershell-5-1/

## This could be Active Directory, a text file, a SQL database, whatever
$computers = Get-AdComputer -Filter *

foreach ($c in $computers.Name) {
    try {
        $session = New-PSSession -ComputerName $c
        $icmParams = @{
            Session = $session
        }

        $output = @{
            ComputerName = $c
        }
        ## In case they're running Powerhell v3
        $icmParams.ScriptBlock = { $env:PSModulePath; [Environment]::GetEnvironmentVariable("PSModulePath", "Machine") }
        $output.PSModulePath = (Invoke-Command @icmParams) -split ';' | Select-Object -Unique | Sort-Object

        ## Grab the existing version
        $icmParams.ScriptBlock = { $PSVersionTable.BuildVersion.ToString() }
        $output.PSModulePath = Invoke-Command @icmParams

        ## Check .NET Framework 4.5.2
        if (Get-ChildItem -Path "\\$c\c$\windows\Microsoft.NET\Framework" -Directory | Where-Object {$_.Name -match '^v4.5.2.*' }) {
            $output.DotNetGood = $true
        } else {
            $output.DotNetGood = $false
        }
        [pscustomobject]$output
    } catch {

    } finally {
        Remove-PSSession -Session $session -ErrorAction Ignore
    }
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
## This could be Active Directory, a text file, a SQL database, whatever
$computers = Get-AdComputer -Filter *
 
foreach ($c in $computers.Name) {
    try {
        $session = New-PSSession -ComputerName $c
        $icmParams = @{
            Session = $session
        }
 
        $output = @{
            ComputerName = $c
        }
        ## In case they're running Powerhell v3
        $icmParams.ScriptBlock = { $env:PSModulePath; [Environment]::GetEnvironmentVariable("PSModulePath", "Machine") }
        $output.PSModulePath = (Invoke-Command @icmParams) -split ';' | Select-Object -Unique | Sort-Object
 
        ## Grab the existing version
        $icmParams.ScriptBlock = { $PSVersionTable.BuildVersion.ToString() }
        $output.PSModulePath = Invoke-Command @icmParams
 
        ## Check .NET Framework 4.5.2
        if (Get-ChildItem -Path "\\$c\c$\windows\Microsoft.NET\Framework" -Directory | Where-Object {$_.Name -match '^v4.5.2.*' }) {
            $output.DotNetGood = $true
        } else {
            $output.DotNetGood = $false
        }
        [pscustomobject]$output
    } catch {
 
    } finally {
        Remove-PSSession -Session $session -ErrorAction Ignore
    }
}