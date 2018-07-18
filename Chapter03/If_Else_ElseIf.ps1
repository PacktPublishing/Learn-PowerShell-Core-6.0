<#

# starting with the if keyword and followed by the condition in parentheses
if (conditional statement) 
{
    #if conditional statement was
}
#the else area is optional
else
{
    #if conditional statement was not met
}

#>


# creating variable for common test
$emptyVariable = ""
$variableForConditions = "Test123"

# To validate, if a string has been correctly filled, you can use this method.
# You can try to replace the $emptyVariable with $variableForConditions and testing it again.
if ($emptyVariable -eq "")
{
    #empty      
    Write-Output 'empty' # <---
}
else 
{    
    #not empty  
    Write-Output 'not empty'
}

####

# short-written
if ($emptyVariable)
{
    #not empty      
    Write-Output 'not empty'
}
else 
{    
    #empty  
    Write-Output 'empty' # <---
}

###

# short-written negated
if (-not $emptyVariable)
{
    #empty    
    Write-Output 'empty' # <---
}
else 
{    
    #not empty  
    Write-Output 'not empty'
}

###

# like statement and condition chain
# validate if $variableForConditions is like 'test0*'
if ($variableForConditions -like 'test0*')
{
    #not like "Test*'"
    Write-Output 'like "Test*"'
}
# validate if $variableForConditions is like 'Test*'
elseif ($variableForConditions -like 'Test*') 
{    
    #-like 'Test*'  
    Write-Output '-like Test*' # <--
}
else 
{
    #something else
    Write-Output 'something else'
}
