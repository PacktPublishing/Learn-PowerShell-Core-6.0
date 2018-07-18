#string
$varWithString = "Test"

#int
$varWithInt = 5

#get type
$varWithString.GetType()
$varWithInt.GetType()

#working with strings
$varCombined = $varWithString + $varWithInt
$varCombined #Test5

#calculation
$calculatedVar = $varWithInt + 5
$calculatedVar #10