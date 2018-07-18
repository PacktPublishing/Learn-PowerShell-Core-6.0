#Static Class of System Environment
[System.Environment]::OSVersion.Version


#Usage of static class Math

#region Properties

#PI
[Math]::PI #3,14159265358979

#E
[Math]::E #2,71828182845905

#endregion

#region Methods

#Showing all static methods
[System.Math] | Get-Member -Static -MemberType Methods

#Showing all static properties
[System.Math] | Get-Member -Static -MemberType Methods

##Showing all static methods and properties
[System.Math] | Get-Member -Static


[Math]::Min
<#
    OverloadDefinitions
    -------------------
    static sbyte Min(sbyte val1, sbyte val2)
    static byte Min(byte val1, byte val2)
    static int16 Min(int16 val1, int16 val2)
    static uint16 Min(uint16 val1, uint16 val2)
    static int Min(int val1, int val2)
    static uint32 Min(uint32 val1, uint32 val2)
    static long Min(long val1, long val2)
    static uint64 Min(uint64 val1, uint64 val2)
    static float Min(float val1, float val2)
    static double Min(double val1, double val2)
    static decimal Min(decimal val1, decimal val2)
#>
[Math]::Min(3,9) #3

[Math]::Pow
<#
    OverloadDefinitions
    -------------------
    static double Pow(double x, double y)
#>

[Math]::Pow(2,3) # 2^3 = 2*2*2 = 8


#endregion