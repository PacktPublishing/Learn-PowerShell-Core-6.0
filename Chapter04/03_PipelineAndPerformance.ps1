#region What happens when piping things?
function UsesPipeline
{
    param
    (
        [Parameter(ValueFromPipeline)]
        [string]
        $PipedObject
    )

    begin
    {
        # Optional - will be executed once before any object is retrieved from the pipeline
        # Usually used to initialize things like service connections or variables
        Write-Host -ForegroundColor Yellow 'Let the processing begin!'
        $pipedObjectList = New-Object -TypeName 'System.Collections.Generic.List[string]'
    }

    process
    {
        # Mandatory - each object passing down the pipeline will go through the entire
        # block once
        # The more expensive the processing is here, the longer it will take!
        $pipedObjectList.Add($PipedObject)
    }

    end
    {
        # Optional - Will be executed once after all objects have been retrieved from the pipeline.
        # Clean-up tasks are usually placed here
        Write-Host -ForegroundColor Yellow "We're done here..."
        return $pipedObjectList
    }
}

$null | UsesPipeline
$objects = 1..100000 | UsesPipeline
#endregion

#region Examining Foreach-Object

# Notice the parameters Begin, Process and End - know them from somewhere?
Get-Command -Syntax -Name ForEach-Object

# What countless people write
Get-ChildItem | ForEach-Object {$_.BaseName}

# Even worse
Get-ChildItem | % {$_.BaseName}

# What it actually means
Get-ChildItem | ForEach-Object -Process {$_.BaseName}

# The begin and end blocks have the exact same purpose as they had in our function
Get-ChildItem |
    ForEach-Object -Begin {
    Write-Host 'Calculating hashes'
} -Process {
    Get-FileHash -Path $_.FullName
} -End {
    Write-Host 'Hashes returned'
}
#endregion

#region Performance of Foreach-Object vs .ForEach() vs foreach(a in b)
$inputObjects = 1..10

# Slowest
$startCmdlet = Get-Date
$folders = $inputObjects | Foreach-Object {'Folder{0:d2}' -f $_}
$endCmdlet = Get-Date

# Still slow
$startLinq = Get-Date
$folders = $inputObjects.ForEach( {'Folder{0:d2}' -f $_})
$endLinq = Get-Date

# Acceptable
$startConstruct = Get-Date
$folders = foreach ($i in $inputObjects)
{
    'Folder{0:d2}' -f $i
}
$endConstruct = Get-Date

$timeCmdlet = ($endCmdlet - $startCmdlet).Ticks
$timeLinq = ($endLinq - $startLinq).Ticks
$timeConstruct = ($endConstruct - $startConstruct).Ticks

Write-Host ('foreach-Construct was {0:p} faster than the LINQ-like query, and {1:p} faster than Foreach-Object!' -f ($timeLinq / $timeConstruct), ($timeCmdlet / $timeConstruct))
#endregion

#region Performance of Where-Object
$startConstruct = Get-Date
$fastFiles = Get-ChildItem -Recurse -Path $env:SystemRoot -Filter *.dll -ErrorAction SilentlyContinue
$endConstruct = Get-Date

$startLinq = Get-Date
$mediumFiles = (Get-ChildItem -Recurse -Path $env:SystemRoot -ErrorAction SilentlyContinue).Where({$_.Extension -eq '.dll'})
$endLinq = Get-Date

$startCmdlet = Get-Date
$slowFiles = Get-ChildItem -Recurse -Path $env:SystemRoot -ErrorAction SilentlyContinue | Where-Object -Property Extension -eq .dll
$endCmdlet = Get-Date

$timeCmdlet = ($endCmdlet - $startCmdlet).Ticks
$timeLinq = ($endLinq - $startLinq).Ticks
$timeConstruct = ($endConstruct - $startConstruct).Ticks

Write-Host ('Where-Construct was {0:p} faster than the LINQ-like query, and {1:p} faster than Where-Object!' -f ($timeLinq / $timeConstruct), ($timeCmdlet / $timeConstruct))
#endregion