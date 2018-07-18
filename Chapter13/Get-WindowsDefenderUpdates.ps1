#requires -Version 3.0 

function Get-UpdateInstalled([Parameter(Mandatory)]$KBNumber)
{
    $Session = New-Object -ComObject "Microsoft.Update.Session"
    $Searcher = $Session.CreateUpdateSearcher()
    $historyCount = $Searcher.GetTotalHistoryCount()

    $status = @{
        Name="Operation"
        Expression= {
            switch($_.operation)
            {
                1 {"Installation"}
                2 {"Uninstallation"}
                3 {"Other"}
            }
        }
    }

    $Searcher.QueryHistory(0, $historyCount) | 
    Where-Object {$_.Title -like "*KB$KBNumber*" } |
    Select-Object -Property Title, $status, Date
}

function Test-UpdateInstalled([Parameter(Mandatory)]$KBNumber)
{
    $update = Get-UpdateInstalled -KBNumber $KBNumber |
    Where-Object Status -eq Installation |
    Select-Object -First 1
      
    return $update -ne $null
}

Test-UpdateInstalled -KBNumber 2267602
Get-UpdateInstalled -KBNumber 2267602 | Out-GridView