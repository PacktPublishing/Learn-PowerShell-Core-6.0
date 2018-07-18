# Initialization of variables
$numericValue = 42
$stringValue = 'Password.'
$hashtable = @('This', 'is', 'a', 'test', '!', 42)

# -eq
$numericValue -eq 42 # true
$numericValue -eq 24 # false

# -ne
$stringValue -ne 42 # true
$hashtable[5] -ne 42 # false

# -gt
$numericValue -gt 41 # false
$stringValue.Length -gt 5 # true
$hashtable.Count -gt 6 #false

# -ge
$numericValue -ge 41 # false
$stringValue.Length -ge 5 # true
$hashtable.Count -ge 6 #true

# -lt
$numericValue -lt 41 # true
$stringValue.Length -lt 5 # false
$hashtable.Count -lt 6 # false

# -le
$numericValue -le 41 # true
$stringValue.Length -le 5 # false
$hashtable.Count -le 6 # true

# -like
$stringValue -like '*Password.*' # true
$stringValue -like '42' # false

# -notlike
$stringValue -notlike '*Password.*' # false
$stringValue -notlike '42' # true

# -match
$stringValue -match 'Pass' # true
$Matches # Name = 0; Value = Pass
$hashtable -match 'is' # 'This', 'is'

# -notmatch
$hashtable -notmatch 'is' # 'a', 'test', !, 42

# -contains
$hashtable -contains 42 # true
$stringValue -contains 'Pass' # false
# contains validates collections and not strings - this is a typical error

# -notcontains
$hashtable -notcontains 4 # true
# not an exact match

# -in
42 -in $hashtable # true
'Pass' -in $stringValue # false
# in validates collections and not strings - this is a typical error
4 -in $hashtable # false
# not an exact match

# -notin
4 -notin $hashtable # true
# not an exact match, but negated
'is' -notin $hashtable # false
# an exact match - negated

