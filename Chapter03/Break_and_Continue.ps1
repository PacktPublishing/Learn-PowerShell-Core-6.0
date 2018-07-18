# simple example for break in a do-while loop
$a = 0
do 
{    
    $a++
    $a
    if ($a -gt 2) 
    {
        break;    
    }
}
while ($a -lt 5)
# 1, 2, 3

# simple example for a continue in a foreach-loop
$stringArray = 'Pow', 'er','Shell', 42
foreach ($obj in $stringArray)
{
    if ($obj -like '*er*') 
    {
        continue;    
    }
    Write-Host $obj
}
# 'Pow', 'Shell', '42'