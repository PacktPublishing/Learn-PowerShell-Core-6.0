#region JSON vs HashTable
# Hashtable
@{
    PropertyName = 'Value'
    ListProperty = @(
        'ListEntry1'
        'ListEntry2'
    )
} | convertto-json -dept 100 | clip

# JSON
@"
{
    "ListProperty":  [
                         "ListEntry1",
                         "ListEntry2"
                     ],
    "PropertyName":  "Value"
}
"@
#endregion

#region Create the API
$polarisPath = [System.IO.Path]::GetTempFileName() -replace '\.tmp','\Polaris'
git clone https://github.com/powershell/polaris $polarisPath
Import-Module $polarisPath

$middleWare = @"
    `$PolarisPath = '$polarisPath\FileSvc'
    if (-not (Test-Path `$PolarisPath))
    {
        [void] (New-Item `$PolarisPath -ItemType Directory)
    }
    if (`$Request.BodyString -ne `$null)
    {
        `$Request.Body = `$Request.BodyString | ConvertFrom-Json
    }
    `$Request | Add-Member -Name PolarisPath -Value `$PolarisPath -MemberType NoteProperty
"@

New-PolarisRouteMiddleware -Name JsonBodyParser -ScriptBlock ([scriptblock]::Create($middleWare)) -Force

# Create
New-PolarisPostRoute -Path "/files" -Scriptblock {
    if (-not $request.Body.Name -or -not $request.Body.Content)
    {
        $response.SetStatusCode(501)
        $response.Send("File name and file content may not be empty.")
        return    
    }

    [void] (New-Item -ItemType File -Path $Request.PolarisPath -Name $request.Body.Name -Value $request.Body.Content)
} -Force

# Read
New-PolarisGetRoute -Path "/files" -Scriptblock {

    $gciParameters = @{
        Path = $Request.PolarisPath
        Filter = '*'
        ErrorAction = 'SilentlyContinue'
    }

    $gciParameters.Filter = if ($request.Query['Name'])
    {
        $request.Query['Name']
    }
    elseif ($request.Body.Name)
    {
        $request.Body.Name
    }

    $files = Get-ChildItem @gciParameters | Select-Object -Property @{Name = 'Name'; Expression = {$_.Name}},@{Name = 'Content'; Expression = {$_ | Get-Content -Raw}}

    $Response.Send(($files | ConvertTo-Json));
} -Force

# Update
New-PolarisPutRoute -Path "/files" -Scriptblock {
    if (-not $request.Body.Name -or -not $request.Body.Content)
    {
        $response.SetStatusCode(501)
        $response.Send("File name and file content may not be empty.")
        return    
    }

    [void] (Set-Content -Path (Join-Path $Request.PolarisPath $request.Body.Name) -Value $request.Body.Content)
} -Force

# Delete
New-PolarisDeleteRoute -Path "/files" -Scriptblock {
    $fileName = if ($request.Query['Name'])
    {
        $request.Query['Name']
    }
    elseif ($request.Body.Name)
    {
        $request.Body.Name
    }
    else
    {
        $response.SetStatusCode(501)
        $response.Send("File name may not be empty.")
        return    
    }
    
    Remove-Item -Path (Join-Path $Request.PolarisPath -ChildPath $fileName)
} -Force

Start-Polaris
#endregion

#region interaction
$jsonBody = @{
    Name = 'testfile.txt'
    Content = 'This is almost too easy'
} | ConvertTo-Json

$jsonBodyUpdate = @{
    Name = 'testfile.txt'
    Content = 'It works like a charm'
} | ConvertTo-Json

# Create
Invoke-RestMethod -Method Post -Uri http://localhost:8080/files -Body $jsonBody -ContentType application/json

# Read - Invoke-RestMethod converts from JSON automatically

# All files
Invoke-RestMethod -Method Get -Uri http://localhost:8080/files

# Specific file
Invoke-RestMethod -Method Get -Uri http://localhost:8080/files?Name=testfile.txt

# Update
Invoke-RestMethod -Method Put -Uri http://localhost:8080/files -Body $jsonBodyUpdate -ContentType application/json

# Delete
Invoke-RestMethod -Method Delete -Uri http://localhost:8080/files?Name=testfile.txt

#endregion