# simple example for joining strings
-join 'P', 'ower', 'Shell' # 'P', 'ower', 'Shell'  # not working as planned
-join ('P', 'ower', 'Shell') # 'PowerShell' 

# initialize variable 
$strings = 'P', 'ower', 'Shell'
-join $strings # 'PowerShell'

##

# joining with a specified delimeter
('This', 'is', 'PowerShell.') -join ' ' # This is PowerShell.
'This', 'is', 'PowerShell.' -join ' ' # This is PowerShell.
'ID', 'USER', 'NAME' -join '|' # ID|USER|NAME