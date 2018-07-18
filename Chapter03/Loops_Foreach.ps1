# simple syntax of a foreach-loop
# foreach ($<item> in $<collection>)
# {
#     <statement list>
# }


# simple example for a foreach-loop
$stringArray = 'Pow', 'er','Shell', 42
foreach ($obj in $stringArray)
{
    Write-Host $obj
}
# 'Pow', 'er', 'Shell', '42'