# Initialization of variables
$numericValue = 1.337
$stringValue = 'Let make PowerShell great'

# combining expressions with -and
# try always to use parentheses to prevent errors and make the code better readable
($numericValue -gt 1) -and ($stringValue -like '*PowerShell*') # true
($numericValue -gt 2) -and ($stringValue -like '*PowerShell*') # false
($numericValue -gt 2) -and ($stringValue -like '*Power1Shell*') # false

# combining expressions with -or
($numericValue -gt 1) -or ($stringValue -like '*PowerShell*') # true
($numericValue -gt 2) -or ($stringValue -like '*PowerShell*') # true
($numericValue -gt 2) -or ($stringValue -like '*Power1Shell*') # false

# combining expressions with -xor
($numericValue -gt 1) -xor ($stringValue -like '*PowerShell*') # false
($numericValue -gt 2) -xor ($stringValue -like '*PowerShell*') # true
($numericValue -gt 2) -xor ($stringValue -like '*Power1Shell*') # false

# negate with -not and !
($numericValue -gt 1) -and -not ($stringValue -like '*PowerShell*') # false
! ($numericValue -gt 2) -and ($stringValue -like '*PowerShell*') # true
! ($numericValue -gt 2) -and -not ($stringValue -like '*Power1Shell*') # true