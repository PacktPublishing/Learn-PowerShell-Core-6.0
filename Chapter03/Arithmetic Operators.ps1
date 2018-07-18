#region arithmetic operators with numeric values

# add
133 + 877 # 1000
2 + "file" # ERROR

# subtract
1337 - 337 # 1000

# multiply
3 * 9 # 27
3 + 3 * 3 # 12 -> punctuation is respected 3 + (3 * 3)

# divide
3 + 3 / 3 # 4 -> punctuation is respected 3 + (3 / 3) 

# negative number
-17 + 5 # -12

# modulo
17 % 6 # 5 -> 12/6 -> 5 left

# shift-left
2 -shl 1 # 4     bits 00000010 -> 00000100
3 -shl 1 # 6     bits 00000011 -> 00000110

# shift-right
65 -shr 1 # 32   bits 00100001 -> 00100000
66 -shr 2 # 16   bits 01000010 -> 00010000

#endregion

#region arithmetic operators with strings

# add 
"word" + "chain" # "wordchain"
"word" + 2 # "word2"

# subtract
"wordchain" - "chain" # ERROR

#divide
"wordchain" / "chain" # ERROR

#multiply
"wordchain" * 2 # "wordchainwordchain"
"wordchain" * "w" # ERROR

#shift
"wordchain" -shr 1 # ERROR

#endregion

#region arithmetic operators with arrays / hashtables

# this creates an array with the values 123 and "test"
123, "test"

# add
123, "test" + 3 # 123, "test", 3

# subtract
123, "test" - 123 # ERROR

# divide
123, "test" / 123 # ERROR

# multiply
123, "test" * 2 # 123, "test", 123, "test"

#endregion

#region operator precedence

- (12 + 3) # -15
- 12 + 3 # -9
6 + 6 / 3 # 8
(6 + 6) / 3 # 4

#endregion