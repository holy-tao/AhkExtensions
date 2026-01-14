#Requires AutoHotkey v2.0

#Include ./YUnit/Assert.ahk
#Include ./YUnit/Yunit.ahk
#Include ./YUnit/Stdout.ahk

#Include ../NumberExtensions.ahk

class NumberExtensionTests {
    IsInteger_WithIntegerFloat() => Assert.Equals(Number("1.00").IsInteger, false)
    IsInteger_WithNonIntegerFloat() => Assert.Equals(Number("1.5").IsInteger, false)
    IsInteger_WithPureInteger() => Assert.Equals(Number("1").IsInteger, true)

    IsFloat_WithPureInteger() => Assert.Equals(Number("1").IsFloat, false)
    IsFloat_WithPureFloat() => Assert.Equals(Number("3.14").IsFloat, true)
    IsFloat_WithIntegerFloat() => Assert.Equals(Number("1.00").IsFloat, true)

    Abs() => Assert.Equals(-5.Abs(), 5)
    Round() => Assert.Equals(0.95.Round(), 1)
    Round_WithPrecision() => Assert.Equals(0.888.Round(1), 0.9)

    Ceil() => Assert.Equals(1.2.Ceil(), 2)
    Floor() => Assert.Equals(1.8.Floor(), 1)
    Ceil_Negative() => Assert.Equals((-1.2).Ceil(), -1)
    Floor_Negative() => Assert.Equals((-1.2).Floor(), -2)

    Sqrt() => Assert.Equals(100.Sqrt(), 10.0)
    Mod() => Assert.Equals(10.Mod(3), 1)

    Sin_Zero() => Assert.Equals(0.Sin(), 0)
    Cos_Zero() => Assert.Equals(0.Cos(), 1)
    Tan_Zero() => Assert.Equals(0.Tan(), 0)

    ASin_Zero() => Assert.Equals(0.ASin(), 0)
    ACos_One() => Assert.Equals(1.ACos(), 0)
    ATan_Zero() => Assert.Equals(0.ATan(), 0)

    Clamp_Instance_Below() => Assert.Equals((-5).Clamp(0, 10), 0)
    Clamp_Instance_Within() => Assert.Equals(5.Clamp(0, 10), 5)
    Clamp_Instance_Above() => Assert.Equals(15.Clamp(0, 10), 10)
    Clamp_Static() => Assert.Equals(Number.Clamp(15, 0, 10), 10)

    ExpLn() => Assert.Equals(1.Exp().Ln(), 1)
    Log_Base10() => Assert.Equals(100.Log(), 2)
}

class FloatExtensionTests {
    Truncate_Longer() => Assert.Equals(1.11111111.Truncate(3), "1.111")
    Truncate_Shorter() => Assert.Equals(1.0.Truncate(3), "1.000")

    IsNan_True() => Assert.Equals(Float.IsNaN(Float.NaN), true)
    IsNaN_False() => Assert.Equals(Float.IsNaN(1.0), false)

    IsInfinity_64_True() => Assert.Equals(Float.IsInfinity(Float.NegativeInfinity), true)
    IsInfinity_32_True() => Assert.Equals(Float.IsInfinity(Float.NegativeInfinity32), true)
    IsInfinity_False() => Assert.Equals(Float.IsInfinity(Float.Max), false)
}

class IntegerExtensionTests {

}

if(A_ScriptName == "NumberExtensions.test.ahk") {
    Yunit.Use(YUnitStdOut)
        .Test(NumberExtensionTests, FloatExtensionTests, IntegerExtensionTests)
}