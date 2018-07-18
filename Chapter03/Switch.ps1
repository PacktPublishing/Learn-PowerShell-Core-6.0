# Basic implementation of switch
#
# Switch (<test-value>)
# {
#     <condition> {<action>}
#     <condition> {<action>}
# }
#

# Simple example
switch (42)
 {
    1 {"It is one."}
    2 {"It is two."}
    42 {"It is the answer of everything."}
 }

# "It is the answer of everything.""

# Simple example - various input values
switch (42, 2)
 {
    1 {"It is one."}
    2 {"It is two."}
    42 {"It is the answer of everything."}
 }
# "It is the answer of everything."
# "It is two."

#example using Regex
switch -Regex ("fourtytwo")
       {
           1 {"It is one."; Break}
           2 {"It is two."; Break}
           "fo*" {"It is the answer of everything."}
       }
# "It is the answer of everything."