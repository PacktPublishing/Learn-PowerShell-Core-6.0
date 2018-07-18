#region Jobs

# Part 1: Parallelity built-in
$machines = 1..32 | ForEach-Object {'NODE{0:d2}' -f $_}
$scriptBlock = {
    Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ID      = 6005
    } -MaxEvents 50
}

$startInvoke1 = Get-Date
$events = Invoke-Command -ComputerName $machines -ScriptBlock $scriptBlock
$endInvoke1 = Get-Date

$startInvoke2 = Get-Date
$events = Invoke-Command -ComputerName $machines -ScriptBlock $scriptBlock -ThrottleLimit 16
$endInvoke2 = Get-Date

Write-Host ('ThrottleLimit 32: {0}s' -f ($endInvoke1 - $startInvoke1).TotalSeconds)
Write-Host ('ThrottleLimit 16: {0}s' -f ($endInvoke2 - $startInvoke2).TotalSeconds)

# Using jobs explicitly
$start = Get-Date
$jobs = 1..50 | ForEach-Object {
    Start-Job -ScriptBlock { Start-Sleep -Seconds 1}
}
$jobs | Wait-Job
$end = Get-Date

$jobs | Remove-Job
$end - $start # Not THAT parallel
Write-Host ('It took {0}s to sleep 50*1s in 50 jobs' -f ($end - $start).TotalSeconds)
#endregion

#region Runspaces

# Grab the logical processors to set the upper boundary for our runspace pool
# This sample only sleeps, but imagine running high-load scripts in multiple parallel runspaces.
$proc = Get-CimInstance -ClassName CIM_Processor
$runspacepool = [runspacefactory]::CreateRunspacePool(1, $proc.NumberOfLogicalProcessors, $Host) 
$runspacepool.Open()

# We need to collect the handles to query them later on
$Handles = New-Object -TypeName System.Collections.ArrayList

# Queue 1000 jobs
1..1000 | Foreach-Object {
    $posh = [powershell]::Create() 
    $posh.RunspacePool = $runspacepool

    # Add your script and parameters. Note that your script block may of course have parameters
    $null = $posh.AddScript( {
            param
            (
                [int]$Seconds
            )
            Start-Sleep @PSBoundParameters})
    $null = $posh.AddArgument(1)


    [void] ($Handles.Add($posh.BeginInvoke()))
}

$start = Get-Date
while (($handles | Where IsCompleted -eq $false).Count)
{
    Start-Sleep -Milliseconds 100
}
$end = Get-Date

Write-Host ('It took {0}s to sleep 1000*1s in up to {1} parallel runspaces' -f ($end - $start).TotalSeconds, $proc.NumberOfLogicalProcessors)

# When done: Clean up
$runspacepool.Close()
$runspacepool.Dispose()

#endregion

#region Additional cmdlets

# Sample from github.com/nightroman/SplitPipeline
Measure-Command { 1..10 | . {process { $_; sleep 1 }} }
Measure-Command { 1..10 | Split-Pipeline {process { $_; sleep 1 }} }
Measure-Command { 1..10 | Split-Pipeline -Count 10 {process { $_; sleep 1 }} }

# A practical example: Hash calculation
Measure-Command { Get-ChildItem -Path $PSHome -File -Recurse | Get-FileHash } #2.3s
Measure-Command { Get-ChildItem -Path $PSHome -File -Recurse | Split-Pipeline {process {Get-FileHash -Path $_.FullName}} } # 0.6s

#endregion