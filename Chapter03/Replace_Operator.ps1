# Simple usage of -replace
'PowerShell is hard.' -replace 'hard', 'easy' # 'PowerShell is easy.'

# Using Regex to switch words
"PowerShell Awesomeness" -replace '(.*) (.*)','$2 $1' # 'Awesomeness PowerShell'

# Explaining the example with -match
"PowerShell Awesomeness" -match '(.*) (.*)'
$Matches

# Name                           Value
# ----                           -----
# 2                              Awesomeness
# 1                              PowerShell
# 0                              PowerShell Awesomeness

$Matches[0] # PowerShell Awesomeness
$Matches[1] # PowerShell
$Matches[2] # Awesomeness