#region Collections
# Declaring an array
$emptyArray = @()
$preFilledArray = 'value1','value2','value3'
$arrayFromCmdlet = Get-Process
$arrayFromRange = 10..20

# Observing the type (Object[])
$preFilledArray.GetType().FullName

# Declaration with type-cast
[string[]]$onlyStringsHere = 'value1'
$onlyStringsHere.GetType().FullName # System.String[]

# Accessing array entries
$preFilledArray[0] # All lists have a zero-based index
$preFilledArray[-1] # A handy shortcut to that last element of a list
$arrayFromCmdlet[2,4,8] # Get elements 2, 3 and 8
$arrayFromCmdlet[3..5] # Get elements 3,4 and 5

# Finding elements in Arrays
$preFilledArray.Contains('value1') # Inherited from IList

# Caution: IndexOf returns -1 if
# the element is not found. This would lead you to the last array entry.
$idx = $preFilledArray.IndexOf('value1') 
$preFilledArray[$idx]

# Exploring arrays
Get-Member -InputObject @()

# Methods prefixed by IList are inherited and not necessarily implemented
# Or are implemented different than you would expect
$preFilledArray.Remove('value2') # Throws
$preFilledArray.Add('value4') # Throws
$preFilledArray.Clear() # Sets each array entry to $null, elements remain!
$preFilledArray[2] -eq $null # true
$preFilledArray.Count # 3

# Arrays are so-called reference types
$arrayOne = 'Python', 'Is', 'Awesome'
$arrayTwo = $arrayOne
$arrayTwo[0] = 'PowerShell'
$arrayOne -join ' ' # Only a pointer is copied and changing the downstream object changes the reference as well

# More collections
$arrayList = [System.Collections.ArrayList]::new()
$arrayList.Add('value')
$arrayList.Add((Get-Date)) # ArrayList does not have a type for its values
$arrayList.AddRange((1..10)) # You can add whole ranges to an array list

#endregion