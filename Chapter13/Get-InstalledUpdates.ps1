Function Get-InstalledUpdates
{
		<#	
		.SYNOPSIS
			Get-InstalledUpdates gets a list of Windows and Microsoft Updates installed on the computer.
		
		.DESCRIPTION
			Get-InstalledUpdates gets a list of Windows and Microsoft Updates installed on the computer. Requires administrative level access.
		
		.PARAMETER ComputerName
			A description of the ComputerName parameter.
		
		.EXAMPLE
			Get-InstalledUpdates -ComputerName "localhost"
			
		.EXAMPLE
			Get-Content computers.txt | Get-InstalledUpdates
		
		.NOTES
			Get-InstalledUpdates gets a list of Windows and Microsoft Updates installed on the computer.
	#>
	[CmdletBinding()]
    Param (
        [Parameter(position=0,Mandatory = $False,ValueFromPipeline =
        $true,ValueFromPipelinebyPropertyName=$true)][Alias('Name')] 
        $ComputerName = $env:computername
	)
	Begin
	{
		function Test-ElevatedShell
		{
			$user = [Security.Principal.WindowsIdentity]::GetCurrent()
			(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
		}
		$admin = Test-ElevatedShell
	}
	PROCESS
	{
		If($admin)
		{
			[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.Update.Session') | Out-Null
    		$Session = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$ComputerName))
    		$Searcher = $Session.CreateUpdateSearcher()
    		$historyCount = $Searcher.GetTotalHistoryCount()
    		$Searcher.QueryHistory(0, $historyCount) | Select-Object Date,
    		@{name="Operation"; expression={switch($_.operation){
    		1 {"Installation"}; 2 {"Uninstallation"}; 3 {"Other"}}}},
    		@{name="Status"; expression={switch($_.resultcode){
			1 {"In Progress"}; 2 {"Succeeded"}; 3 {"Succeeded With Errors"};
			4 {"Failed"}; 5 {"Aborted"}
			}}}, Title,@{name="KB"; expression={($_.title -split "(KB*.*)")[1]}},@{name="PC";expression={$ComputerName}}
		}
		else
		{
			"Please re-load this function in a Run as Administrator PowerShell console."
		}
	}
}

