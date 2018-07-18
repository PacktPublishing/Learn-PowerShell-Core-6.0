#region Script blocks
# A script block without parameters
{
    "Something is happening here"
}

# Executing a script block
({
    "Something is happening here"
}).Invoke()

# Or use the ampersand
& {
    "Something is happening here"
}

# With parameters
$scriptBlockArgs = {
    # Built-in - not recommended
    "$($args[0]) is happening here"
}

# Better
$scriptBlockParam = {
    param
    (
        [string]
        $TheThing
    )
    # Built-in - not recommended
    "$TheThing is happening here"
}

$scriptBlockArgs.Invoke('Something')

# Named parameters are possible
$scriptBlockParam.Invoke('Something')
& $scriptBlockParam -TheThing SomeThing

#region Parameter Attribute

# The basic parameter attribute
param
(
    [Parameter()]
    $YourParameter
)

# A mandatory parameter
param
(
    [Parameter(Mandatory)]
    $YourParameter
)

# A help message for mandatory parameters
param
(
    [Parameter(
        Mandatory,
        HelpMessage = 'This is visible when needed'
        )]
    $YourParameter
)

# Hidden Parameters
function fun
{
    param
    (
        [Parameter(DontShow)]
        $CatchMeIfYouCan
    )

    $CatchMeIfYouCan
}

# VSCode is too intelligent, ISE will not show IntelliSense
# Tab expansion not possible, Parameter can still be used
fun -CatchMeIfYouCan 'value'

# Parameter set
function parametersets
{
    param
    (
        [Parameter(ParameterSetName = 'Set1')]
        $InSet1,

        [Parameter(ParameterSetName = 'Set2')]
        $InSet2,

        $InAllSetsByDefault
    )
}

# Pipeline input

# ByValue
function pipelineByValue
{
    param
    (
        [Parameter(ValueFromPipeline)]
        [string]
        $Parameter
    )

    begin
    {
        $count = 0
    }

    process
    {
        $count ++
        Write-Host $Parameter
    }

    end
    {
        Write-Host "$count values processed"
    }
}

"a","b","c" | pipelineByValue

function pipelineByProperty
{
    param
    (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $BaseName
    )

    begin
    {
        $count = 0
    }

    process
    {
        $count ++
        Write-Host $BaseName
    }

    end
    {
        Write-Host "$count values processed"
    }
}

Get-ChildItem | pipelineByProperty
#endregion

#region cmdletbinding
function withbinding
{
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    param
    ( )

    if ($PSCmdlet.ShouldProcess('Target object','Action'))
    {
        Write-Host 'User answered yes in confirmation'
    }
}
withbinding -WhatIf
withbinding
withbinding -Confirm:$false
#endregion
#endregion

#region Dynamic functions
New-Item -Path function:\MyFunction -Value {param($Id) Get-Process -Id $Id}
MyFunction -id $pid
& (Get-Item Function:\MyFunction) -id $pid
#endregion

#region from spaghetti code to functions
# The legacy code
$prinfo = Get-CimInstance -Query 'SELECT * FROM CIM_Processor'

if (-not (Test-Path -Path D:\Logs))
{
    New-Item -Path D:\Logs -ItemType Directory
}

"$((Get-Date).ToString('yyyy-MM-dd hh:mm:ss')):`tFound $($prinfo.NumberOfCores) cores with $($prinfo.NumberOfLogicalProcessors) logical processors" | Out-File -FilePath D:\Logs\$((Get-Date).ToString('yyyyMMdd'))_SysInfo.log -Encoding UTF8 -Append

Get-Service | foreach {
    "$((Get-Date).ToString('yyyy-MM-dd hh:mm:ss')):`tService$($_.Name) has status $($_.Status)" | Out-File -FilePath D:\Logs\$((Get-Date).ToString('yyyyMMdd'))_SysInfo.log -Encoding UTF8 -Append
}

"$((Get-Date).ToString('yyyy-MM-dd hh:mm:ss')):`tScript finished" | Out-File -FilePath D:\Logs\$((Get-Date).ToString('yyyyMMdd'))_SysInfo.log -Encoding UTF8 -Append

# The improved code with two functions
function Enable-Logging
{
    [CmdletBinding()]
    [OutputType('System.IO.FileInfo')]
    param
    (
        [Parameter(Mandatory)]
        [String]
        [ValidateScript({
            Test-Path -Path $_ -PathType Leaf
        })]
        $Path
    )

    $logFolder = Split-Path -Path $Path -Parent

    if (-not (Test-Path -Path $logFolder))
    {
        [void] (New-Item -Path $logFolder -ItemType Directory)
    }

    if (Test-Path $Path)
    {
        return (Get-Item $Path)        
    }

    New-Item -ItemType File -Path $Path
}

function Write-Log
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Message,

        [Parameter(Mandatory)]
        $Path
    )

    $logMessage = "{0}:`t{1}" -f (Get-Date).ToString('yyyy-MM-dd hh:mm:ss'),$Message
    Add-Content -Path $Path -Value $logMessage -Encoding UTF8
}

$processorInfo = Get-CimInstance -Query 'SELECT * FROM CIM_Processor'

$log = Enable-Logging -Path "D:\Logs\$((Get-Date).ToString('yyyyMMdd'))_SysInfo.log"

Write-Log -Message "Found $($prinfo.NumberOfCores) cores with $($prinfo.NumberOfLogicalProcessors) logical processors" -Path $log.FullName

foreach ($service in (Get-Service))
{
    Write-Log -Message "Service $($service.Name) has status $($service.Status)" -Path $log.FullName
}

Write-Log -Message "Script finished" -Path $log.FullName
#endregion

#region scoping

# Get-Help about_scopes
$inGlobalScope = 'global'
$private:NoOneShallSeeMe = 'hidden'
function ChildOfGlobal
{
    # can read outer variables that are not private
    Write-Host "Outer variable value: $inGlobalScope"

    # Without scope modifier, cannot write to outer scope
    # What happens: A variable $local:inGlobalScope is created
    # The output is misleading
    $inGlobalScope = 'local'
    Write-Host "Outer variable value: $inGlobalScope"
    Write-Host "Actually, `$local:inGlobalScope was used: $local:inGlobalScope"
    Write-Host "Private variable: $private:NoOneShallSeeMe"
}

ChildOfGlobal
Write-Host "Outer variable after function: $inGlobalScope"
#endregion