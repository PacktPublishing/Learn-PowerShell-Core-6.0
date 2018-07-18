#region Brace placement

#region Curly braces
# Acceptable one-liner if e.g. a condition is not met
if ( -not $condition) {return}

# Good style, closing brace has new line
function Get-SomeThing
{
    # Do your thing
}

Get-SomeThing
#endregion

#region Parentheses

# Spacing
# Bad
if($condition){
    "do Stuff"
}

# Good
if ($condition)
{
    "Do stuff"
}

# Use parentheses to make expressions apparent
# Bad
if (3 -gt 2 -and (Get-Date).DayOfWeek -eq 'Friday')
{
    'Good things happen'
}

# Good
if ((3 -gt 2) -and ((Get-Date).DayOfWeek -eq 'Friday'))
{
    'Good things happen'
}

#endregion

#endregion

#region Naming conventions

#region Casing
# Bad
function Get-SomeThing
{
    param
    (
        $parametername
    )
    
    $somevariable
}

# Good
function Get-SomeThing
{
    param
    (
        $ParameterName
    )

    $someVariable
}
#endregion

#region Naming

# Bad
$w = 640
$h = 480
[System.Drawing.Rectangle]::new(0,0,$w,$h)

# Good
$width = 640
$height = 480
[System.Drawing.Rectangle]::new(0,0,$width,$height)

# Bad
$a = 'contoso.com'
$aa = $false
$b = 'administrator'

while (-not $aa)
{
    $bb = Get-AdUser $b -Server $a -ErrorAction SilentlyContinue
    if ($bb) {$aa = $true}
}

$bb | Set-AdUser -EmployeeNumber 42

# Good
$domainName = 'contoso.com'
$userCreated = $false
$samAccountName = 'administrator'
$employeeNumber = 42

while (-not $userCreated)
{
    $userObject = Get-AdUser $samAccountName -Server $domainName -ErrorAction SilentlyContinue
    if ($userObject) {$userCreated = $true}
}

$userObject | Set-AdUser -EmployeeNumber $employeeNumber

#endregion

#region Aliases, parameter names

# Does this look appealing to you? If so, perl might be your choice ;)
gsv | ? CanStop | spsv -ea SilentlyContinue -wh -pa

# Bad
gci C:\temp -ea SilentlyContinue
gsv | ? CanStop

# Good
Get-ChildItem -Path C:\temp -ErrorAction SilentlyContinue
Get-Service | Where-Object -Property CanStop

# Reducing nesting
function foo
{
    param
    (
        $Param1
    )

    # This horrible creation
    if ($Param1)
    {
        if (Test-Path $Param1)
        {
            if ((Get-Date).Date -eq '4/20')
            {
                # Do things
                # Hard to maintain deeply nested code
                $false
            }
            else
            {
                $true
            }
        }
    }

    # looks better like this simply by inverting statements
    if (-not $Param1) { return }
    if (-not (Test-Path -Path $Param1)) { return }

    # No last if statement necessary for simple code block
    return (-not ((Get-Date).Date -eq '4/20'))
}

#endregion

#region General readability

# Bad
Invoke-Command -ComputerName Node1.contoso.com,Node2.contoso.com -ScriptBlock { ... }

# Good
Invoke-Command -ComputerName Node1.contoso.com, Node2.contoso.com -ScriptBlock { ... }

# Bad
Set-ADUser -Identity janhendrik -AccountExpirationDate (Get-Date).AddMonths(6) -City Duesseldorf -Country Germany -Company 'Contoso Ltd.' -Department 'R & D' -DisplayName 'Jan-Hendrik Peters' -GivenName 'Jan-Hendrik' -Surname Peters

# Good
$userParameters = @{
    Identity              = 'janhendrik'
    AccountExpirationDate = (Get-Date).AddMonths(6)
    City                  = 'Duesseldorf'
    Country               = 'Germany'
    Company               = 'Contoso Ltd.'
    Department            = 'R & D'
    DisplayName           = 'Jan-Hendrik Peters'
    GivenName             = 'Jan-Hendrik'
    Surname               = 'Peters'
}

Set-ADUser @userParameters

#endregion

#region function style

# Proper naming with the approved verbs
# Adding a company prefix distinguishes your cmdlet from builtin ones
# Bad
function foo {
    'does something'
}

# Good
function Get-ContosoVm
{
    'does something'
}

# CmdletBinding to allow common parameters
function Get-ContosoVm
{
    [CmdletBinding()]
    param ( )

    'does something'
}

# Parameters in functions

<#
.SYNOPSIS
    Deprovisions a VM
#>
function Remove-ContosoVm
{
    [CmdletBinding()]
    param
    (
        # A comma-separated list of VM names to deprovision
        [Parameter(
            Mandatory,
            HelpMessage = 'Please enter a comma-separated list of VM names'
        )]
        [string[]]
        $ComputerName,

        # An optional timeout in minutes for this operation
        [Parameter()]
        [int]
        $TimeoutInMinutes = 5
    )
}

# Cmdlet syntax is properly displayed
Get-Command -Syntax -Name Remove-ContosoVm

# Help is populated properly
Get-Help -Name Remove-ContosoVm -Parameter TimeoutInMinutes

#endregion
#endregion

#region Function output

function Get-ContosoFile
{
    [CmdletBinding()]
    [OutputType('System.IO.FileInfo')]
    param
    (
        [string]
        $Path
    )
}
Get-ContosoFile | Where-Object -Property # TAB or Ctrl-Space here

# Adding a custom type name to your object
function Get-Bob
{
    [CmdletBinding()]
    [OutputType('Contoso.Bob')]
    param
    ( )

    [PSCustomObject]@{
        PSTypeName = 'Contoso.Bob'
        Name = 'Bob'
    }
}

Get-Bob | Get-Member
(Get-Command Get-Bob).OutputType

# Utilizing Write-cmdlets

function Remove-ContosoVm
{
    [CmdletBinding()]
    param
    (
        # A comma-separated list of VM names to deprovision
        [Parameter(
            Mandatory,
            HelpMessage = 'Please enter a comma-separated list of VM names'
        )]
        [string[]]
        $ComputerName,

        # An optional timeout in minutes for this operation
        [Parameter()]
        [int]
        $TimeoutInMinutes = 5
    )

    Write-Verbose -Message "Deprovisioning $ComputerName"
    Write-Verbose -Message "Shutting down $ComputerName"
    
    foreach ($machine in $ComputerName)
    {
        Write-Debug -Message 'Calling Hyper-V cmdlets to shut down machine'

        if ($true)
        {
            Write-Error -Message 'Could not shut down VM prior to removing it.' -TargetObject $machine
        }
    }
}

Remove-ContosoVm -ComputerName node1
Remove-ContosoVm -ComputerName node1,node2 -Verbose
Remove-ContosoVm -ComputerName node1,node2 -Verbose -ErrorAction SilentlyContinue
#endregion

#region Compatibility

# Consider using a requires-statement (Get-Help about_requires) to denote what your script needs
#Requires -Version 5.1 -Modules @{ModuleName="Storage";ModuleVersion="2.0.0.0"}

#endregion

#region comments

# Bad

# Sets value to 42
$illegibleVariable = 42

# Good

# Initialize repetition interval for scheduled task
$taskRepetitionMinutes = 42

#region Regions can be
#region nested
Code
#endregion
#endregion
#endregion

#region Header/Disclaimer

# Consider developing a default template for your company's header

<#
Author:  Employee Of The Month
Purpose: Decommissioning of servers in DEV, QA and PRD
Status:  Released
Date:    2018-05-11

  Copyright (C) 2018 A Successful Company
  All rights reserved.
 
       A Successful Company
       123 PowerShell Drive
       City, State
       
       https://www.ASuccessfulCompany.com
 
 DISCLAIMER OF WARRANTIES:
 
 THE SOFTWARE PROVIDED HEREUNDER IS PROVIDED ON AN "AS IS" BASIS, WITHOUT
 ANY WARRANTIES OR REPRESENTATIONS EXPRESS, IMPLIED OR STATUTORY; INCLUDING,
 WITHOUT LIMITATION, WARRANTIES OF QUALITY, PERFORMANCE, NONINFRINGEMENT,
 MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  NOR ARE THERE ANY
 WARRANTIES CREATED BY A COURSE OR DEALING, COURSE OF PERFORMANCE OR TRADE
 USAGE.  FURTHERMORE, THERE ARE NO WARRANTIES THAT THE SOFTWARE WILL MEET
 YOUR NEEDS OR BE FREE FROM ERRORS, OR THAT THE OPERATION OF THE SOFTWARE
 WILL BE UNINTERRUPTED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

#endregion