# Get the module
if (-not (Get-Module ConvertTo-Breakpoint -List))
{
    Install-Module ConvertTo-Breakpoint -Scope CurrentUser -Force
}

# Execute the entire script and see your breakpoints appear
# Execute the script a second time to be placed in your breakpoint ;)
Write-Error 'Good lord... This went wrong'

$Error[0] | ConvertTo-Breakpoint

# In case of errors bubbling up, you can set breakpoints at
# all positions
function foo
{
    [CmdletBinding()]
    param ( )
    throw 'Bad things happen'
}
function bar
{
    [CmdletBinding()]
    param ( )
    try
    {
        foo -ErrorAction Stop
    }
    catch
    {
       Write-Error -Exception $_ 
    }
}
function baz
{
    bar -ErrorAction Continue
}
baz

# Now we get three break points.
# One at baz, where the exception bubbles up to
# One in baz, where bar is called
# One in bar, where the error of foo is rethrown 
$error[0] | ConvertTo-Breakpoint -All