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
}

if(A_ScriptName == "ArrayExtensions.Test.ahk") {
    YUnit.Use(YUnitStdOut).Test(ArrayExtensionTests)
}