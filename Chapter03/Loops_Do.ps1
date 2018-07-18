# do-loop with while condition - simple syntax
# do 
# {
#     <statement list>
# }
# while (<condition>)

# do-loop with until condition - simple syntax
# do 
# {
#     <statement list>
# }
# until (<condition>)

# simple example for do-while loop
$a = 0
do 
{    
    $a++
    $a
}
while ($a -lt 5)
# 1, 2, 3, 4, 5

# simple example for do-until loop
$a = 0
do 
{    
    $a++
    $a
}
until ($a -gt 4)
# 1, 2, 3, 4, 5