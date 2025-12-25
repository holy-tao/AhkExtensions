#Requires AutoHotkey v2.0

#Include ./YUnit/Assert.ahk
#Include ./YUnit/Yunit.ahk
#Include ./YUnit/Stdout.ahk

#Include ../ArrayExtensions.ahk

class ArrayExtensionTests {

    Sort_WithComparer_SortsArrayAscending() {
        arr := [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
        arr.Sort((a, b) => a - b)
        Assert.ArraysEqual([1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9], arr)
    }

    Sort_WithComparer_SortsArrayDescending() {
        arr := [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
        arr.Sort((a, b) => b - a)
        Assert.ArraysEqual([9, 6, 5, 5, 5, 4, 3, 3, 2, 1, 1], arr)
    }

    Sorted_WithComparer_ReturnsSortedCloneAscending() {
        arr := [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
        sorted := arr.Sorted((a, b) => a - b)

        Assert.ArraysEqual([1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9], sorted)
        Assert.ArraysEqual([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5], arr)
    }

    Sorted_WithComparer_ReturnsSortedCloneDescending() {
        arr := [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
        sorted := arr.Sorted((a, b) => b - a)

        Assert.ArraysEqual([9, 6, 5, 5, 5, 4, 3, 3, 2, 1, 1], sorted)
        Assert.ArraysEqual([3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5], arr)
    }

    Reverse_ReversesArray() {
        arr := [1, 2, 3, 4, 5]
        arr.Reverse()

        Assert.ArraysEqual([5, 4, 3, 2, 1], arr)
    }

    Reversed_ReturnsReversedClone() {
        arr := [1, 2, 3, 4, 5]
        reversed := arr.Reversed()

        Assert.ArraysEqual([5, 4, 3, 2, 1], reversed)
        Assert.ArraysEqual([1, 2, 3, 4, 5], arr)
    }

    BinarySearch_WithComparer_FindsElement() {
        arr := [1, 2, 3, 4, 5]
        index := arr.BinarySearch(3, (a, b) => a - b)

        Assert.Equals(3, index)
    }

    BinarySearch_WithComparer_FindsElementNotPresent() {
        arr := [1, 2, 3, 4, 5]
        index := arr.BinarySearch(6, (a, b) => a - b)

        Assert.Equals(-1, index)
    }

    BinarySearch_WithComparer_FindsElementNotPresentInEmptyArray() {
        arr := []
        index := arr.BinarySearch(1, (a, b) => a - b)

        Assert.Equals(-1, index)
    }

    ForEach_WithAction_CallsActionForAllElements() {
        arr := [1, 2, 3]
        result := []
        arr.ForEach((element) => result.Push(element))

        Assert.ArraysEqual([1, 2, 3], result)
    }

    FirstOrDefault_WithMatchingElement_FindsElement() {
        arr := [1, 2, 3, 4, 5]

        result := arr.FirstOrDefault((el) => el > 3)
        Assert.Equals(result, 4)
    }

    FirstOrDefault_WithNoMatchingElement_ReturnsArrayDefault() {
        arr := [1, 2, 3, 4, 5]
        arr.Default := -1

        result := arr.FirstOrDefault((el) => el > 5)
        Assert.Equals(result, -1)
    }

    FirstOrDefault_WithNoMatchingElementAndProvidedDefault_ReturnsProvidedDefault() {
        arr := [1, 2, 3, 4, 5]

        result := arr.FirstOrDefault((el) => el > 5, -1)
        Assert.Equals(result, -1)
    }

    FirstOrDefault_WithNoMatchingElement_PrefersProvidedDefault() {
        arr := [1, 2, 3, 4, 5]
        arr.Default := -1

        result := arr.FirstOrDefault((el) => el > 5, 99)
        Assert.Equals(result, 99)
    }

    FirstOrDefault_WithNoDefaultAndNoProvidedDefault_ThrowsUnsetError() {
        arr := [1, 2, 3, 4, 5]
        Assert.Throws((*) => arr.FirstOrDefault(el => el > 5), UnsetError)
    }

    FirstOrDefault_WithNoCondition_ReturnsFirstElement() {
        arr := [1, 2, 3, 4, 5]
        Assert.Equals(arr.FirstOrDefault(), 1)
    }

    First_WithMatchingElement_FindsElement() {
        arr := [1, 2, 3, 4, 5]
        result := arr.First(el => el > 2)
        Assert.Equals(result, 3)
    }

    First_WithNoMatchingElement_ThrowsTargetError() {
        arr := [1, 2, 3, 4, 5]
        Assert.Throws((*) => arr.First(el => el > 10), TargetError)
    }

    First_WithNoMatchingElement_ReturnsFirstElement() {
        arr := [1, 2, 3, 4, 5]
        Assert.Equals(arr.First(), 1)
    }

    First_WithEmptyArray_ThrowsTargetError() {
        arr := []
        Assert.Throws((*) => arr.First(), TargetError)
    }

    SingleOrDefault_WithSingleMatchingElement_ReturnsIt() {
        arr := [1, 2, 3, 4, 5]
        result := arr.SingleOrDefault(el => el > 4)
        Assert.Equals(result, 5)
    }

    SingleOrDefault_WithMultipleMatchingElements_ThrowsTargetError() {
        arr := [1, 2, 3, 4, 5]
        Assert.Throws((*) => arr.SingleOrDefault(el => el > 3), TargetError)
    }

    SingleOrDefault_WithNoMatchingElement_ReturnsArrayDefault() {
        arr := [1, 2, 3, 4, 5]
        arr.Default := -1
        result := arr.SingleOrDefault(el => el > 5)
        Assert.Equals(result, -1)
    }

    SingleOrDefault_WithNoMatchingElementAndProvidedDefault_ReturnsProvidedDefault() {
        arr := [1, 2, 3, 4, 5]
        result := arr.SingleOrDefault(el => el > 5, -1)
        Assert.Equals(result, -1)
    }

    SingleOrDefault_WithNoMatchingElement_PrefersProvidedDefault() {
        arr := [1, 2, 3, 4, 5]
        arr.Default := 99
        result := arr.SingleOrDefault(el => el > 5, -1)
        Assert.Equals(result, -1)
    }

    SingleOrDefault_WithNoMatchingElementAndNoDefaults_ThrowsUnsetErrorError() {
        arr := [1, 2, 3, 4, 5]
        Assert.Throws((*) => arr.SingleOrDefault(el => el > 5), UnsetError)
    }

    Single_WithSingleMatchingElement_ReturnsIt() {
        arr := [1, 2, 3, 4, 5]
        result := arr.Single(el => el > 4)
        Assert.Equals(result, 5)
    }

    Single_WithMultipleMatchingElements_ThrowsTargetError() {
        arr := [1, 2, 3, 4, 5]
        Assert.Throws((*) => arr.Single(el => el > 3), TargetError)
    }

    Single_WithEmptyArray_ThrowsTargetError() {
        arr := []
        Assert.Throws((*) => arr.Single(el => el > 3), TargetError)
    }

    Map_MapsItems() {
        arr := [1, 2, 3, 4, 5]
        mapped := arr.Map(i => i * 2)

        Assert.ArraysEqual(mapped, [2, 4, 6, 8, 10])
        Assert.ArraysEqual(arr, [1, 2, 3, 4, 5])
    }

    Filter_FiltersItems() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        filtered := arr.Filter(v => v <= 5)

        Assert.ArraysEqual(filtered, [1, 2, 3, 4, 5])
        Assert.ArraysEqual(arr, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }

    Slice_WithTwoPositiveIndices_ReturnsSliceFromStart() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        slice := arr.Slice(2, 4)

        Assert.ArraysEqual(slice, [2, 3, 4])
    }

    Slice_WithTwoNegativeIndices_ReturnsSliceFromEnd() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        slice := arr.Slice(-4, -2)

        Assert.ArraysEqual(slice, [7, 8, 9])
    }

    Slice_WithSinglePositiveIndex_ReturnsItemsToEnd() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        slice := arr.Slice(5)

        Assert.ArraysEqual(slice, [5, 6, 7, 8, 9, 10])
    }

    Slice_WithSingleNegativeIndex_ReturnsItemsToEnd() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        slice := arr.Slice(-4)

        Assert.ArraysEqual(slice, [7, 8, 9, 10])
    }

    Slice_WithInvalidIndices_ThrowsValueError() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        Assert.Throws((*) => arr.Slice(5, 1), ValueError)
        Assert.Throws((*) => arr.Slice(-1, -5), ValueError)
    }

    All_WhereConditionIsMet_ReturnsTrue() {
        arr := [1, 2, 3]
        Assert.Equals(arr.All(el => el > 0), true)
    }

    All_WhereConditionIsUnmet_ReturnsFalse() {
        arr := [-1, 2, 3]
        Assert.Equals(arr.All(el => el > 0), false)
    }

    Any_WhereConditionIsMet_ReturnsTrue() {
        arr := [1, -2, -3]
        Assert.Equals(arr.Any(el => el > 0), true)
    }

    Any_WhereConditionIsNotMet_ReturnsFalse() {
        arr := [1, 2, 3]
        Assert.Equals(arr.All(el => el <= 0), false)
    }

    Any_WithEmptyCallbackAndNonEmptyArray_ReturnsTrue() {
        Assert.Equals([1].Any(), true)
    }

    Any_WithEmptyCallbackAndEmptyArray_ReturnsFalse(){
        Assert.Equals([].Any(), false)
    }

    ToString_WithPrimitives_ReturnsStringArray() {
        arr := [1, 2, 3, 4, 5]
        Assert.Equals(String(arr), "[1, 2, 3, 4, 5]")
    }

    Reduce_With2ParamCallback_ReducesArray() {
        arr := [1, 1, 1, 1, 1]
        val := arr.Reduce((a, b) => a + b)

        Assert.Equals(val, 5)
    }

    Reduce_WithCallableObject_ReducesArray() {
        obj := { Call: (a, b) => a + b }
        arr := [1, 1, 1, 1, 1]
        val := arr.Reduce(obj)

        Assert.Equals(val, 5)
    }

    Reduce_WithInitialValue_UsesIt() {
        arr := [1, 1, 1, 1, 1]
        val := arr.Reduce((a, b) => a + b, 5)

        Assert.Equals(val, 10)
    }

    Reduce_With3ParamCallback_ReducesArray() {
        arr := [1, 2, 3, 4, 5]
        out := []

        arr.Reduce((a, b, i) => out.Push(b + i), 1)
        Assert.ArraysEqual(out, [2, 4, 6, 8, 10])
    }

    Reduce_With4ParamCallback_ReducesArray() {
        arr := [1, 1, 1, 1, 1]
        arr.Reduce((a, b, i, self) => self[i] := a + b + i, 1)

        Assert.ArraysEqual(arr, [3, 6, 10, 15, 21])
    }

    Reduce_WithUncallableCallback_ThrowsValueError() {
        arr := [1, 2, 3]
        Assert.Throws((*) => arr.Reduce({}), ValueError)
    }

    Reduce_WithCallbackWithTooFewParams_ThrowsValueError() {
        arr := [1, 2, 3]
        Assert.Throws((*) => arr.Reduce(a => a), ValueError)
    }

    Reduce_WithCallbackWithTooManyParams_ThrowsValueError() {
        arr := [1, 2, 3]
        Assert.Throws((*) => arr.Reduce((a, b, c, d, e) => a), ValueError)
    }

    Shift_ShiftsItem() {
        arr := [1, 2, 3]
        val := arr.Shift()

        Assert.Equals(val, 1)
        Assert.ArraysEqual(arr, [2, 3])
    }

    Unshift_WithOneValue_UnshiftsItem() {
        arr := [1, 2, 3]
        arr.Unshift(0)

        Assert.ArraysEqual(arr, [0, 1, 2, 3])
    }

    Unshift_WithMultipleValues_UnshiftsItem() {
        arr := [1, 2, 3]
        arr.Unshift(-2, -1, 0)

        Assert.ArraysEqual(arr, [-2, -1, 0, 1, 2, 3])
    }

    SequenceEquals_WithEqualSequencesAndDefaultComparator_ReturnsTrue() {
        arr1 := [1, 2, 3], arr2 := [1, 2, 3]
        YUnit.Assert(arr1.SequenceEquals(arr2))
    }

    SequenceEquals_WithUnqualSequencesAndDefaultComparator_ReturnsFalse() {
        arr1 := [1, 2, 3], arr2 := [-1, -2, -3]
        YUnit.Assert(!arr1.SequenceEquals(arr2))
    }

    SequenceEquals_WithCustomComparator_UsesIt() {
        arr1 := [1, 2, 3], arr2 := [-1, -2, -3]
        Yunit.Assert(arr1.SequenceEquals(arr2, (*) => true))
    }

    Fill_WithTwoPositiveIndices_FillsRange() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        arr.Fill(0, 2, 4)

        Assert.ArraysEqual(arr, [1, 0, 0, 0, 5, 6, 7, 8, 9, 10])
    }

    Fill_WithTwoNegativeIndices_FillsRange() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        arr.Fill(0, -4, -2)

        Assert.ArraysEqual(arr, [1, 2, 3, 4, 5, 6, 0, 0, 0, 10])
    }

    Fill_WithSinglePositiveIndex_FillsItemsToEnd() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        arr.Fill(0, 5)

        Assert.ArraysEqual(arr, [1, 2, 3, 4, 0, 0, 0, 0, 0, 0])
    }

    Fill_WithSingleNegativeIndex_FillsItemsToEnd() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        arr.Fill(0, -4)

        Assert.ArraysEqual(arr, [1, 2, 3, 4, 5, 6, 0, 0, 0, 0])
    }

    Fill_WithNoIndices_FillsEntireArray() {
        arr := [1, 2, 3, 4, 5]
        arr.Fill(0)

        Assert.ArraysEqual(arr, [0, 0, 0, 0, 0])
    }

    Fill_WithInvalidIndices_ThrowsValueError() {
        arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        Assert.Throws((*) => arr.Fill(0, 5, 1), ValueError)
        Assert.Throws((*) => arr.Fill(0, -1, -5), ValueError)
    }
}

if(A_ScriptName == "ArrayExtensions.Test.ahk") {
    YUnit.Use(YUnitStdOut).Test(ArrayExtensionTests)
}