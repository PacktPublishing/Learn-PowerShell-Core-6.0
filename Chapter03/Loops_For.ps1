# basic syntax of a for-loop
for (<init>; <condition>; <repeat>)
{
    <statement list>
}

# Simple example - for-loop
for ($i = 0; $i -lt 5; $i++) 
{
    $i    
}
# 0, 1, 2, 3, 4


# Simple example - for-loop - different iterator
for ($g = 0; $g -le 20; $g += 2) 
{
    Write-Host $i
}
# 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20