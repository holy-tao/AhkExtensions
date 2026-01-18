#Requires AutoHotkey v2.0

#Include ./YUnit/Assert.ahk
#Include ./YUnit/Yunit.ahk
#Include ./YUnit/Stdout.ahk

#Include ../MapExtensions.ahk

class MapExtensionTests {

    CaseInsensitive_ReturnsCaseInsensitiveMap(){
        ci := Map.CaseInsensitive()

        Assert.IsType(ci, Map)
        Assert.Equals(ci.CaseSense, "Off") ; This doesn't come out as a true Boolean; it's a String
        Assert.Equals(ci.Count, 0)
    }

    WithCaseSense_SetsCaseSense() {
        csOff := Map().WithCaseSense("Off")
        csOn := Map().WithCaseSense("On")

        Assert.Equals(csOff.CaseSense, "Off")
        Assert.Equals(csOn.CaseSense, "On")
    }

    CaseInsensitive_WithStartingPairs_ReturnsCaseInsensitiveMap() {
        ci := Map.CaseInsensitive("one", 1, "two", 2)

        Assert.IsType(ci, Map)
        Assert.Equals(ci.CaseSense, "Off") ; This doesn't come out as a true Boolean; it's a String
        Assert.MapsEqual(ci, Map("one", 1, "two", 2))
    }

    CaseInsensitive_WithOddNumberOfStartingPairs_ThrowsValueError() {
        Assert.Throws((*) => Map.CaseInsensitive("one", 1, "two"), ValueError)
    }

    ForEach_EnumeratesAllValues() {
        test := Map(1, "1", 2, "2", 3, "3")
        out := Map()

        test.ForEach((k, v) => out[k] := v)
        Assert.MapsEqual(test, out)
    }

    Filter_FiltersValues() {
        test := Map()
        Loop(10)
            test[A_Index] := "Item " A_Index

        out := test.Filter((key, val) => key < 3)

        Assert.MapsEqual(out, Map(1, "Item 1", 2, "Item 2"))
    }

    All_WhereConditionIsMet_ReturnsTrue() {
        test := Map()
        Loop(10)
            test[A_Index] := "Item " A_Index

        Yunit.Assert(test.All((key, value) => IsInteger(key) && (value is String)))
    }

    All_WhereConditionIsNotMet_ReturnsFalse() {
        test := Map()
        Loop(10)
            test[A_Index] := "Item " A_Index

        Yunit.Assert(!test.All((key, value) => IsFloat(key) && (value is String)))
    }

    Any_WithConditionWhereConditionIsMet_ReturnsTrue() {
        test := Map()
        Loop(10)
            test[A_Index] := "Item " A_Index

        Yunit.Assert(test.Any((key, value) => key < 10))
    }

    Any_WithConditionWhereConditionIsNotMet_ReturnsTrue() {
        test := Map()
        Loop(10)
            test[A_Index] := "Item " A_Index

        Yunit.Assert(!test.Any((key, value) => key > 10))
    }

    Any_WithNoConditionAndNonEmptyMap_ReturnsTrue() {
        test := Map(1, 1)
        Yunit.Assert(test.Any())
    }

    Any_WithNoConditionAndEmptyMap_ReturnsFalse() {
        test := Map()
        Yunit.Assert(!test.Any())
    }
}

if(A_ScriptName == "MapExtensions.Test.ahk"){
    Yunit.Use(YUnitStdOut).Test(MapExtensionTests)
}