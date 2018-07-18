# Testing your own functions
function New-ConfigDbEntry
{
    param
    (
        $ServerInstance = 'localhost\CMDB',

        $Database = 'Devices',

        [Parameter(Mandatory)]
        $ComputerName
    )

    $query = "INSERT INTO {0} VALUES (N'{1}, {2:yyyyMMdd}'" -f $Database, $ComputerName, (Get-Date)

    Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Query $query
}

# Unit tests to test your function as a black box
Describe 'Config DB module' {
    function Invoke-SqlCmd {} # Empty function declaration if SqlServer module is not installed
    Context 'New entry is added' {
        $testParameters = @{
            ServerInstance = 'somemachine\CMDB'
            Database = 'Devices'
        }
        $testObject = 'SomeMachineName'

        # Mock external cmdlet with proper return value
        Mock -CommandName Invoke-SqlCmd

        It 'Should not throw' {
            {New-ConfigDbEntry @testParameters -ComputerName $testObject} | Should -Not -Throw
        }

        It 'Should have called Invoke-SqlCmd once' {
            Assert-MockCalled -CommandName Invoke-SqlCmd -Times 1 -Exactly
        }
    }
}

# Integration test to test if your function modified your infrastructure accordingly
Describe 'Config DB integration' {
    Context 'New entry has been added' {
        $instance = 'localhost\testinstance'
        $database = 'testdb'
        $entry = 'SomeMachineName'
        
        (Invoke-SqlCmd -ServerInstance $instance -Database $database -Query "SELECT ComputerName from $testdb").ComputerName | Should -Contain $entry
    }
}
