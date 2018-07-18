# Update Pester to the current version to make use of the improvements
Get-Module -List Pester # Built-in: 3.4.0

# Update PowerShellGet first
if (-not (Get-Command Install-Module).Parameters.ContainsKey('SkipPublisherCheck'))
{
    Update-Module -Name PowerShellGet -Force
}

# After updating PowerShellGet, make sure to close PowerShell and start a new process
# We are using the new parameter SkipPublisherCheck since newer versions of Pester are not signed
Install-Module -Name Pester -Force -SkipPublisherCheck

# Verify
Get-Module -List Pester

# Excerpt from DSC resource module xActiveDirectory
Describe "$($Global:DSCResourceName)\Get-TargetResource" {

    $testDefaultParameters = @{
        Name = '10.0.0.0/8'
        Site = 'Default-First-Site-Name'
    }

    Context 'Subnet does not exist' {

        Mock -CommandName Get-ADReplicationSubnet

        It 'Should return absent' {

            $result = Get-TargetResource @testDefaultParameters

            $result.Ensure   | Should Be 'Absent'
            $result.Name     | Should Be $testDefaultParameters.Name
            $result.Site     | Should Be ''
            $result.Location | Should Be ''
        }
    }
}

# Mocking .NET calls

# This cannot be tested properly
[System.IO.DriveInfo]::new('N')

# This cannot be tested internally as well, but can be mocked
function Get-DriveInfo
{
    param
    (
        $DriveLetter
    )

    [System.IO.DriveInfo]::new($DriveLetter)
}

Describe SomeTest {
    It 'returns $false for IsReady when the drive does not exist' {
        Mock Get-DriveInfo {[psobject]@{IsReady = $false}}

        (Get-DriveInfo).IsReady | Should Be $false
    }
}

# Give me some context
function LetItSnow
{
    param ([switch]$Delightful)

    if ($Delightful)
    {
        'But the fire is so delightful'
    }
    else
    {
        'Let it snow, let it snow, let it snow'
    }
}
Describe AnotherTest {
    Context 'The weather outside is frightful' {
        $testdata = 'But the fire is so delightful'

        It 'Should be delightful' {
            LetItSnow -Delightful | Should Be $testdata
        }
    }

    Context "Seems there's no place to go" {
        $testdata = 'Let it snow, let it snow, let it snow'

        It 'Should snow' {
            LetItSnow | Should Be $testdata
        }
    }
}

# The It block

Describe OneLastTest {
    It 'Should do things' {
        1 | Should -Be 0 -Because 'the world would spin madly out of control otherwise'
    }
}