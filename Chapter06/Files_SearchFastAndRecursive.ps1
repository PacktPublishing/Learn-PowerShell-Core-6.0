#region retrieving files and folders

#Simple Subfolders
Get-ChildItem -Path 'C:\temp' -Directory

#Recurse
Get-ChildItem -Path 'C:\Windows' -Directory -Recurse 

#Simple Subfiles
Get-ChildItem -Path 'C:\temp' -File

#Recurse
Get-ChildItem -Path 'C:\Windows' -File -Recurse 

#endregion

#Define a location where txt files are included. 
$Dir = 'C:\temp\'

#region retrieving *.txt files recursively

#Filtering with .Where()
$timeWhere = (Measure-Command {(Get-ChildItem $Dir -Recurse -Force -ErrorAction SilentlyContinue).Where({$_.Extension -like '*txt*'})}).TotalSeconds
$countWhere = $((Get-ChildItem $Dir -Recurse -Force -ErrorAction SilentlyContinue).Where({$_.Extension -like '*txt*'})).Count

#Filtering with Where-Object
$timeWhereObject = (Measure-Command {(Get-ChildItem $Dir -Recurse -Force -ErrorAction SilentlyContinue) | Where-Object {$_.Extension -like '*txt*'}}).TotalSeconds
$countWhereObject = $((Get-ChildItem $Dir -Recurse -Force -ErrorAction SilentlyContinue) | Where-Object {$_.Extension -like '*txt*'}).Count

#Filtering with Include
$timeInclude = (Measure-Command {Get-ChildItem -Path "$($Dir)*" -Include *.txt* -Recurse}).TotalSeconds
$countInclude = $(Get-ChildItem -Path "$($Dir)*" -Include *.txt* -Recurse).Count

#Using cmd.exe and dir - fastest
$timeCmd = (Measure-Command {cmd.exe /c "cd $Dir & dir *.txt /s /b"}).TotalSeconds
$countCmd = $(cmd.exe /c "cd $Dir & dir *.txt /s /b").Count

Write-Host @"

Filtering with .Where():        $timeWhere
Filtering with Where-Object:    $timeWhereObject
Filtering with Include:         $timeInclude
Using cmd.exe and dir:          $timeCmd

All methods retrieved the same amount of line? $($countWhere -eq $countWhereObject -eq $countInclude -eq $countCmd)

"@

#endregion

