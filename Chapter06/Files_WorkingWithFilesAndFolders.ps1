
#user folder
$UserFolders = Get-ChildItem 'c:\users\' -Directory

#Creating archives in each subfolder
foreach ($userFolder in $UserFolders)
{
    New-Item -Path (Join-Path $userFolder.FullName ('{0}_Archive' -f $userFolder.BaseName)) -ItemType Directory -WhatIf
}

[System.IO.Path]::Combine(