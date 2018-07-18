# Validate numeric values
64 -is [int] # true
64 -is [float] # false
64 -is [decimal] # false
(99999999999).GetType() #Int64
99999999999 -is [Int64] #true
99999999999 -isNot [Int] #true
9999999999999999999999999 -is [decimal] #true

# Validate array
(Get-Process) -is [Array]
("b","c") -is [Array]
@(1,2,"d") -is [Array]

# Validate other .NET objects
(Get-Date) -is [DateTime] #True
((Get-Date).ToString()) -is [DateTime] #false
(Get-Process PowerShell)[0] -is [System.Diagnostics.Process]

# Casting
(1000 -as [DateTime]) -is [DateTime] #true
([int]"676").GetType() #Int32
[int]"676f" #Error
[int]"676.765468" # 677 - automatic rounding to the specified type