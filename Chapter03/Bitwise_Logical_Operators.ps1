# Convert integer 128 into binary
[Convert]::ToString(128,2) # 10000000

# Convert binary 10000000 into integer
[Convert]::ToInt32(10000000,2) # 128

# 132 and 127 in binary
[Convert]::ToString(132,2) # 10000100
[Convert]::ToString(127,2) # 01111111

# -band
# we operate the band operator between 127 and 132
127 -band 132 # 4
# only binary values, which are matching in both values will keep
# 10000100   <-- 127
# 01111111   <-- 132
# --------
# 00000100   <-- 4
[Convert]::ToInt32(00000100,2) # 4

# -bor
# we operate the bor operator between 127 and 132
127 -bor 132 # 255
# binary values, which are available in one of both values will keep
# 10000100   <-- 127
# 01111111   <-- 132
# --------
# 11111111   <-- 255
[Convert]::ToInt32(11111111,2) # 255

# -bxor
# we operate the bxor operator between 127 and 132
127 -bxor 132 # 251
# only binary values, which are in one of both values will keep
# duplicates will be ignored
# 10000100   <-- 127
# 01111111   <-- 132
# --------
# 11111011   <-- 251
[Convert]::ToInt32(11111011,2) # 251

# -bnot
# we operate the bnot operator on 10
-bnot 10 # -11
# all binary values are negated
# 0000 0000 0000 1010     <--   10
# -------------------
# 1111 1111 1111 0101     <--  -11 xfffffff5