#region assignment operators with numeric values

#initial assignment
$numericValue = 123 # 123

# $NumericValue = $NumericValue + 877
# $NumericValue = 123 + 877
$numericValue += 877 # 1000

# $NumericValue = $NumericValue - 500
# $NumericValue = 1000 - 500
$numericValue -= 500 # 500

# $NumericValue = $NumericValue * 2
# $NumericValue = 500 * 2
$numericValue *= 2 # 1000

# $NumericValue = $NumericValue / 10
# $NumericValue = 1000 / 10
$numericValue /= 10 # 100

# $NumericValue = $NumericValue % 3
# $NumericValue = 100 % 3
$numericValue %= 3 # 1

#endregion

#region assignment operators with strings

#initial assignment
$stringValue = "ThisIsAString" # "ThisIsAString"

# $stringValue = $stringValue + "!"
# $stringValue = "ThisIsAString" + "!"
$stringValue += "!" # "ThisIsAString!"

# $stringValue = $stringValue - "!"
# $stringValue = "ThisIsAString" - "!"
$stringValue -= 3 # ERROR

# $stringValue = $stringValue * 2
# $stringValue = 500 * 2
$stringValue *= 2 # "ThisIsAString!ThisIsAString!"

# $stringValue = $stringValue / 10
# $stringValue = 1000 / 10
$stringValue /= "this" # ERROR

# $stringValue = $stringValue % 3
# $stringValue = 100 % 3
$stringValue %= "Val" #ERROR

#endregion

#region assignment operators with arrays / hashtables

#initial assignment
$array = 123, "test"
$hashtable = @(321,"tset")

# $array = $array + 877
# $array = (123, "test") + 877
$array += 877 # (123, "test", 877)

# $array = $array - 500
$array -= 877 # Error

# $NumericValue = $NumericValue * 2
# $NumericValue = (123, "test", 877) * 2
$array *= 2 # (123, "test", 877, 123, "test", 877)

# $array = $array / 2
$array /= 2 # ERROR

# $array = $array % 3
$numericValue %= 3 # ERROR

# $hashtable = (321, "tset") + (321, "tset")
$hashtable  += $hashtable  # (321, "tset", 321, "tset")

# $hashtable = $hashtable + $array
# (321, "tset", 321, "tset") + (123, test, 877, 123, test, 877)
$hashtable += $array # (321, tset, 321, tset, 123, test, 877, 123, test, 877)

#endregion
