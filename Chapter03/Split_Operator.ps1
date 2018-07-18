# simple usage of -split
-split "PowerShell makes fun." # 'PowerShell', 'makes', 'fun.'

##

# using your own delimiter 
'ID:Name' -split ':' # 'ID', 'Name'

##

# using your own delimiter - preserving delimeter
'ID:Name' -split '(:)' # 'ID', ':' ,'Name'

# using your own delimiter - preserving delimeter - omitting specific characters
'ID/:/Name' -split '/(:)/' # 'ID', ':' ,'Name'

##

# using your own delimiter with 3 maximum substrings
'ID:Name:Street:City' -split ':',3 # 'ID', 'Name', 'Street:City'

##

# using a scriptblock
'ID:Name:Street:City' -split {($_ -eq 'a') -or ($_ -eq 't') } # 'ID:N', 'me:S', 'ree', ':Ci', 'y'

