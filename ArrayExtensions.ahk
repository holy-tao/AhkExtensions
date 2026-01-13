#Requires AutoHotkey v2.0

/**
 * Array-related utilities: sorting, searching, etc. Most methods in ArrayExtensions are
 * defined on Array's prototype in the auto-execute thread, so you can call them directly:
 * 		
 * 		[1, 2, 3, 4, 5].FirstOrDefault((val) => val > 3))
 * 
 * That said, many of the the methods can be called on any {@link https://www.autohotkey.com/docs/v2/Objects.htm#__Enum enumerable object}
 * using the `ArrayExtensions` class directly, though they will always return Arrays:
 * 
 * 		ArrayExtensions.Filter(myEnumerableObject, (val) => IsInteger(val))
 * 
 * For complex queries or when iterating objects where iteration has large overhad (e.g.
 * iterating a SQL result set with a remote cursor), `Query` will provide better performance,
 * as it does not require the creation and destruction of multiple intermediate arrays.
 */
class ArrayExtensions {
	static __New() {
		Array.Prototype.DefineProp("BinarySearch", { Call: (this, target, comparator) => ArrayExtensions.BinarySearch(this, target, comparator) })
		Array.Prototype.DefineProp("Sort", { Call: (this, comparator) => ArrayExtensions.Sort(this, comparator) })
		Array.Prototype.DefineProp("Sorted", { Call: (this, comparator) => ArrayExtensions.Sorted(this, comparator) })
		Array.Prototype.DefineProp("Reverse", { Call: (this) => ArrayExtensions.Reverse(this) })
		Array.Prototype.DefineProp("Reversed", { Call: (this) => ArrayExtensions.Reversed(this) })
		Array.Prototype.DefineProp("ForEach", { Call: (this, callback) => ArrayExtensions.ForEach(this, callback) })
		Array.Prototype.DefineProp("First", { Call: (this, condition?) => ArrayExtensions.First(this, condition?) })
		Array.Prototype.DefineProp("FirstOrDefault", { Call: (this, condition?, default?) => ArrayExtensions.FirstOrDefault(this, condition?, default?) })
		Array.Prototype.DefineProp("Last", { Call: (this, condition?) => ArrayExtensions.Last(this, condition?) })
		Array.Prototype.DefineProp("LastOrDefault", { Call: (this, condition?, default?) => ArrayExtensions.LastOrDefault(this, condition?, default?) })
		Array.Prototype.DefineProp("Single", { Call: (this, condition?) => ArrayExtensions.Single(this, condition?) })
		Array.Prototype.DefineProp("SingleOrDefault", { Call: (this, condition?, default?) => ArrayExtensions.SingleOrDefault(this, condition?, default?) })
		Array.Prototype.DefineProp("Map", { Call: (this, mapper) => ArrayExtensions.Map(this, mapper) })
		Array.Prototype.DefineProp("Filter", { Call: (this, condition) => ArrayExtensions.Filter(this, condition) })
		Array.Prototype.DefineProp("All", { Call: (this, condition) => ArrayExtensions.All(this, condition) })
		Array.Prototype.DefineProp("Any", { Call: (this, condition?) => ArrayExtensions.Any(this, condition?) })
		Array.Prototype.DefineProp("Slice", { Call: (this, start?, end?) => ArrayExtensions.Slice(this, start?, end?) })
		Array.Prototype.DefineProp("ToString", { Call: (this) => ArrayExtensions.ToString(this) })
		Array.Prototype.DefineProp("Reduce", { Call: (this, callback, intialValue?) => ArrayExtensions.Reduce(this, callback, intialValue?) })
		Array.Prototype.DefineProp("Unshift", { Call: (this, vals*) => ArrayExtensions.Unshift(this, vals*) })
		Array.Prototype.DefineProp("Shift", { Call: (this) => ArrayExtensions.Shift(this) })
		Array.Prototype.DefineProp("Fill", { Call: (this, val, start?, end?) => ArrayExtensions.Fill(this, val, start?, end?) })
		Array.Prototype.DefineProp("SequenceEquals", { Call: (this, other, equalityComparer?) => ArrayExtensions.SequenceEquals(this, other, equalityComparer?) })
	}
	
	/**
	 * Sorts an array in place with a user-defined comparison function via quicksort.
	 * @scope PUBLIC
	 * @param {array} arr Array to sort
	 * @param {Func (left, right) => Number} comparator Comparator function. Needs to take two inputs left and right, and return a Number
	 * 			describing the relationship of left to right. The output must be negative if left > right, 0 if left = right, 
	 * 			and positive if left < right.
	 * 
	 * 			;Example: sort numbers in ascending order
	 * 			(left, right) => left - right
	 * @param {Integer} low Low index, for quicksort. Do not use.
	 * @param {Integer} high High index, for quicksort. Do not use.
	 * @revision tbeloney 06/23/25 - Created
	 */
	static Sort(arr, comparator, low?, high?){
		low := low ?? 1
		high := high ?? arr.Length

		;Quit early
		if(low >= high || low <= 0 || arr.Length < 2)
			return

		if(low < high){
			pivot := ArrayExtensions._Partition(arr, comparator, low, high)

			ArrayExtensions.Sort(arr, comparator, low, pivot - 1)		;Sort left side
        	ArrayExtensions.Sort(arr, comparator, pivot + 1, high)		;Sort righ tside
		}
	}

	/**
	 * Returns a {@link ArrayExtensions.Sort sorted} {@link https://www.autohotkey.com/docs/v2/lib/Array.htm#Clone Clone} of `arr`
	 * 
	 * @param {Array} arr Array to sort
	 * @param {Func (left, right) => Number} comparator Comparator function. Needs to take two inputs left and right, and return a Number
	 * 			describing the relationship of left to right. The output must be negative if left > right, 0 if left = right, 
	 * 			and positive if left < right.
	 * 
	 * 			;Example: sort numbers in ascending order
	 * 			(left, right) => left - right
	 * @returns {Array<Any>} a sorted clone of `arr`
	 */
	static Sorted(arr, comparator) {
		clone := arr.Clone()
		ArrayExtensions.Sort(clone, comparator)
		return clone
	}

	/**
	 * @private Quicksort partition function. Do not call directly
	 * @param {Array} arr Array to sort
	 * @param {Func (left, right) => Number} comparator Comparator function. Needs to take two inputs left and right, and return a Number
	 * 			describing the relationship of left to right. The output must be negative if left > right, 0 if left = right, 
	 * 			and positive if left < right. So, to sort an array of Numbers in ascending order: `(left, right) => left - right`
	 * @param {Integer} low Low index
	 * @param {Integer} high High index
	 * @returns {Integer} The calculated pivot
	 */
	static _Partition(arr, comparator, low, high){
		pivot := arr[high]
		i := low

		;In normal languages, for(j = low, j < high, j++)
		Loop(high - low){
			j := A_Index - 1 + low

			if(comparator.Call(arr[j], pivot) <= 0){
				ArrayExtensions.Swap(arr, i, j)
				i += 1
			}
		}

		ArrayExtensions.Swap(arr, i, high)
  		return i
	}
	
	/**
	 * Swaps the items at indexes 1 and 2 in arr in-place
	 * @scope PUBLIC
	 * @param {Array} arr Array to swap items in
	 * @param {Integer} index1 Index of the first item to swap
	 * @param {Integer} index2 Index of the second item to swap
	 */
	static Swap(arr, index1, index2){
		temp := arr[index1]
		arr[index1] := arr[index2]
		arr[index2] := temp
	}

	/**
	 * Reverses an array in-place
	 * @scope PUBLIC
	 * @param {Array} arr Array to reverse
	 */
	static Reverse(arr){
		Loop(arr.Length // 2){
			ArrayExtensions.Swap(arr, A_Index, arr.Length - (A_Index - 1))
		}
	}

	/**
	 * Returns a {@link ArrayExtensions.Reverse reversed} {@link https://www.autohotkey.com/docs/v2/lib/Array.htm#Clone Clone} of `arr`
	 * 
	 * @param {Array} arr Array to reverse
	 * @returns {Array} a reversed clone of the input
	 */
	static Reversed(arr) {
		clone := arr.Clone()
		ArrayExtensions.Reverse(clone)
		return clone
	}

    /**
     * Performs a binary search of arr for target, returning target's index or -1 if not found. Requires arr to
     * be sorted in ascending order according to `comparator`.
     * @param {Array} arr Array to search. Must be sorted in ascending order
     * @param {Any} target Element to search for
     * @param {Func (left, right) => Number} comparator Comparator function. Needs to take two inputs left and right, and return a Number
	 * 			describing the relationship of left to right. The output must be negative if left > right, 0 if left = right, 
	 * 			and positive if left < right. 
	 * 
	 * 			;Example: numbers sorted in ascending order
	 * 			(left, right) => left - right
     * @return {Integer} Returns the index of target in arr, or -1 if target is not found
     */
    static BinarySearch(arr, target, comparator){
        low :=  1
        high := arr.Length

        while(low <= high) {
            mid := low + ((high - low) // 2)
            diff := comparator.Call(arr[mid], target)

            if(diff == 0){
                return mid
            }
            else if(diff < 0){
                low := mid + 1
            }
            else{
                high := mid - 1
            }
        }

        return -1 ;Not found
    }

	/**
	 * Call a function for every element in an array
	 * @param {Array} arr The array to iterate over
	 * @param {Func (Any) => Any} callback Function to call for every element in the array
	 */
	static ForEach(arr, callback){
		for(item in arr){
			callback.call(item)
		}
	}

	/**
	 * Checks each item in an array sequentially and returns the first that satisfies some condition,
	 * or else the array's {@link https://www.autohotkey.com/docs/v2/lib/Array.htm#Default|default value}.
	 * If the array has no default value, an {@link https://www.autohotkey.com/docs/v2/lib/Error.htm#UnsetError|`UnsetError`}
	 * is thrown.
	 * 
	 * @param {Array<Any>} arr The array to check
	 * @param {Func (Any) => Boolean} condition The condition that the value must satisfy to be returned.
	 * 			If unset, the method simply returns the first value. This function must take a value
	 * 			of the type contained in `arr` and return a boolean.
     * @param {Any} default the default value to return if no value matches `conditon`. If unset, the
     *          method falls back to arr.default
	 * @returns {Any} the first vaue in `arr` that satisfies `conditon`, or a default value if none exist
	 */
	static FirstOrDefault(arr, condition?, default?) {
		condition := condition ?? (*) => true	;If no condition just take first

		for(item in arr){
			if(match := condition.Call(item))
				return item
		}
        
        return default ?? arr.Default
	}
    
    /**
	 * Returns the first value in `arr` which satisfies some condition. 
	 * 
	 * @param {Array<Any>} arr The array to check
	 * @param {Func (Any) => Boolean} condition The condition that the value must satisfy to be returned.
	 * 			If unset, the method simply returns the first value. This function must take a value
	 * 			of the type contained in `arr` and return a boolean.
	 * @throws {TargetError} if no value in `arr` satisfies `condition`
	 * @returns {Any} the first vaue in `arr` that satisfies `conditon`
	 */
    static First(arr, condition?) {
        condition := condition ?? (*) => true ; If no condition just take first
        
        for(item in arr){
			if(match := condition.Call(item))
				return item
		}
        
        throw TargetError("Array contains no elements matching the provided condition", -1)
    }

	/**
	 * Checks each item in an array in reverse order and returns the last that satisfies some condition,
	 * or else the array's {@link https://www.autohotkey.com/docs/v2/lib/Array.htm#Default|default value}.
	 * If the array has no default value, an {@link https://www.autohotkey.com/docs/v2/lib/Error.htm#UnsetError|`UnsetError`}
	 * is thrown.
	 * 
	 * @param {Array<Any>} arr The array to check
	 * @param {Func (Any) => Boolean} condition The condition that the value must satisfy to be returned.
	 * 			If unset, the method simply returns the last value. This function must take a value
	 * 			of the type contained in `arr` and return a boolean.
     * @param {Any} default the default value to return if no value matches `conditon`. If unset, the
     *          method falls back to arr.default
	 * @returns {Any} the last vaue in `arr` that satisfies `conditon`, or a default value if none exist
	 */
	static LastOrDefault(arr, condition?, default?) {
		condition := condition ?? (*) => true	;If no condition just take last

		Loop(arr.Length) {
			index := arr.Length - (A_Index - 1)
			item := arr[index]
			if(match := condition.Call(item))
				return item
		}
        
        return default ?? arr.Default
	}
    
    /**
	 * Returns the last value in `arr` which satisfies some condition. 
	 * 
	 * @param {Array<Any>} arr The array to check
	 * @param {Func (Any) => Boolean} condition The condition that the value must satisfy to be returned.
	 * 			If unset, the method simply returns the last value. This function must take a value
	 * 			of the type contained in `arr` and return a boolean.
	 * @throws {TargetError} if no value in `arr` satisfies `condition`
	 * @returns {Any} the last vaue in `arr` that satisfies `conditon`
	 */
    static Last(arr, condition?) {
        condition := condition ?? (*) => true ; If no condition just take last
        
		Loop(arr.Length) {
			index := arr.Length - (A_Index - 1)
			item := arr[index]
			if(match := condition.Call(item))
				return item
		}
        
        throw TargetError("Array contains no elements matching the provided condition", -2, String(arr))
    }

	/**
	 * Returns the only value in `arr` that satisfies `condition` or a default value
	 * 
	 * @param {Array<Any>} arr The array to check
	 * @param {Func (Any) => Boolean} condition The condition that the value must satisfy to be returned.
	 * 			If unset, the method simply returns the first value. This function must take a value
	 * 			of the type contained in `arr` and return a boolean.
	 * @param {Any} default the default value to return if no value matches `conditon`. If unset, the
     *          method falls back to arr.default
	 * @throws {TargetError} if no value OR multiple values in `arr` satisfy `condition`
	 * @returns {Any} the only vaue in `arr` that satisfies `conditon`
	 */
	static SingleOrDefault(arr, condition?, default?) {
		condition := condition ?? (*) => true
		found := unset

		for(item in arr){
			if(match := condition.Call(item)) {
				if(!IsSet(found)) {
					found := item
				}
				else{
					throw TargetError("Array contains more than one element matching the provided condition", -2, String(arr))
				}
			}
		}

		return found ?? (default ?? arr.Default)
	}

	/**
	 * Returns the only value in `arr` that satisfies `condition`
	 * 
	 * @param {Array<Any>} arr The array to check
	 * @param {Func (Any) => Boolean} condition The condition that the value must satisfy to be returned.
	 * 			If unset, the method simply returns the first value. This function must take a value
	 * 			of the type contained in `arr` and return a boolean.
	 * @throws {TargetError} if no value OR multiple values in `arr` satisfy `condition`
	 * @returns {Any} the only vaue in `arr` that satisfies `conditon`
	 */
	static Single(arr, condition?) {
		condition := condition ?? (*) => true
		found := unset

		for(item in arr){
			if(match := condition.Call(item)) {
				if(!IsSet(found)) {
					found := item
				}
				else{
					throw TargetError("Array contains more than one element matching the provided condition", -2, String(arr))
				}
			}
		}

		if(!IsSet(found)) {
			throw TargetError("Array contains no elements matching the provided condition", -2, String(arr)) 
		}

		return found
	}

	/**
	 * Creates a new array populated with the results of calling a provided function on every element 
	 * in the input array.
	 * 
	 * @param {Array<Any>} arr The input array to map values from
	 * @param {Func (Any) => Any} mapper The mapping function to use. This must take a value of the
	 * 			type contained in `arr` and return any value, which replaces the value in `arr`.
	 * @returns {Array<Any>} A new array populated with the results of calling `mapper` on every element
	 * 			of `arr`.
	 * 
	 * @example <caption>Round all numbers in an array to the nearest Integer</caption>
	 * myArray := [3.14, 2.6, 3, -4.7, 0.12, 9, 42]
	 * intArray := ArrayExtensions.Map(myArray, (item) => Round(item, 0))
	 */
	static Map(arr, mapper){

		mapped := Array(), mapped.Length := arr.Length
		for(i, item in arr){
			mapped[i] := mapper(item)
		}

		return mapped
	}

	/**
	 * Creates a new array populated with only the values of the input array for which `condition` returns
	 * a truthy value
	 * 
	 * @param {Array<Any>} arr The input array to get values from 
	 * @param {Func (Any) => Boolean} condition The condition to evaluate
	 * @returns {Array<Any>} A new array containing only the values in the input array for which
	 * 			`condition` returned a truthy value
	 * @example <caption>Return only the positive values in an array</caption>
	 * myArray := [3, 42, -3, 1, -6]
	 * positives := myArray.Filter((val) => val > 0)
	 */
	static Filter(arr, condition){
		out := []
		for(item in arr){
			if(condition.Call(item)){
				out.Push(item)
			}
		}

		return out
	}

	/**
	 * Returns a shallow copy of a portion of the input array from `start` to `end` (inclusive). These
	 * can be negative to return elements relative to the end of the array.
	 * @param {Array<Any>} arr the input array to get values from 
	 * @param {Integer} start the index to start at. Default is 1
	 * @param {Integer} end the index to end at. Default is `arr.Length` if `start` is positive, or -1
	 * 			if `start` is negative (thus, leaving this value unset causes `Slice` to return all values
	 * 			from `start` to the end of the array)
	 * 
	 * @example <caption>Return items 2-4 of an array</caption>
	 * exampleArray := [1, 2, 3, 4, 5]
	 * slicedArray := exampleArray.Slice(2, 4)
	 * MsgBox(String(slicedArray))	;[2, 3, 4]
	 * 
	 * @example <caption>Return the last two items in an array</caption>
	 * exampleArray := [1, 2, 3, 4, 5]
	 * slicedArray := exampleArray.Slice(-2)
	 * MsgBox(String(slicedArray))	;[4, 5]
	 */
	static Slice(arr, start?, end?){
		start := Integer(start ?? 1)
		end := Integer(end ?? (start < 0? -1 : arr.length))

		if(end < start){
			throw ValueError("Invalid slice - end must refer to an index after start", -2, start . " to " . end)
		}

		sliced := [], sliced.Length := Abs(end - start) + 1
		Loop(sliced.Length){
			i := start + (A_Index - 1)
			sliced[A_Index] := arr[i]
		}
		
		return sliced
	}

	/**
	 * Returns true if `condition` returns a truthy value when called on every value of the
	 * input array.
	 * @param {Array<Any>} arr The input array
	 * @param {Func (Any) => Boolean} condition The condition to evaluate
	 * @returns {Boolean} true if `condition` is true for every value in `arr`, false otherwise
	 */
	static All(arr, condition){
		for(item in arr){
			if(!condition.Call(item)){
				return false
			}
		}

		return true
	}

	/**
	 * Returns true if `condition` returns a truthy value when called on any value of the
	 * input array.
	 * @param {Array<Any>} arr The input array
	 * @param {Func (Any) => Boolean} condition The condition to evaluate
	 * @returns {Boolean} true if `condition` is true for any value in `arr`, false otherwise
	 */
	static Any(arr, condition?){
		; Allows an unset callback to return true if any elements exist
		condition := condition ?? (*) => true

		for(item in arr){
			if(condition.Call(item)){
				return true
			}
		}

		return false
	}

	/**
	 * Creates a string representation of the input array. This allows any array to be used
	 * as the input to [`String()`](https://www.autohotkey.com/docs/v2/lib/String.htm)
	 * @param {Array<Any>} arr the array to convert
	 * @return {String} a String representation of the input array
	 */
	static ToString(arr){
		outStr := "["
		for(item in arr){
			if(!IsSet(item)){
				outStr .= "unset"
			}
			else{
				if(item is VarRef){
					outStr .= "&"
					item := %item%
				}

				if(item is Primitive || item.HasMethod("ToString")){
					outStr .= item is String? ("`"" . item . "`"") :  String(item)
				}
				else{
					outStr .= Type(item)
				}
			}

			if(A_Index < arr.length){
				outStr .= ", "
			}
		}

		return outStr . "]"
	}

	/**
	 * Executes a user-supplied "reducer" callback function on each element of the array, in order, passing 
	 * in the return value from the calculation on the preceding element. The final result of running the reducer 
	 * across all elements of the array is a single value.
	 * 
	 * @param {Array<Any>} arr The input array
	 * @param {Func (accumulator, current[, index, arr]) => Any} callback A function to execute for each 
	 * 			element in the array. Its return value becomes the value of the accumulator parameter on 
	 * 			the next invocation of `callback`. For the last invocation, the return value becomes the 
	 * 			return value of `Reduce()`. If this function is [variadic](https://www.autohotkey.com/docs/v2/Functions.htm#Variadic),
	 * 			all four parameters are passed in. This means that if it is a [`BoundFunc`](https://www.autohotkey.com/docs/v2/misc/Functor.htm#BoundFunc),
	 * 			it will always be passed all four parameters, since bound functions are always variadic and
	 * 			it is impossible to determine the number of arguments it can accept.
	 * 
	 * 			Add(accumulator, current) => accumulator + current
	 * 			CopySumIntoIndex(accumulator, current, index, arr) => arr[index] := accumulator + current
	 * @param {Any} initialValue The starting value of the accumulator. If unset, this is the first value
	 * 			in the array, and iteration begins at index 2
	 */
	static Reduce(arr, callback, initialValue?){
		if(!(callback is Func) && HasMethod(callback)){
			callback := callback.Call	; we need the actual Func so we can inspect its Min/Max params
		}

		if(!(callback is Func)){
			throw ValueError("Invalid reducer callback: Expected a Func, but got a(n) " . Type(callback), -2, callback)
		}

		if(!callback.IsVariadic && (callback.MaxParams < 2 || callback.MinParams > 4)){
			throw ValueError("Invalid reducer callback: Callback must accept between 2 and 4 parameters", -2, callback)
		}

		;if the function is variadic, MaxParams is the maximum number of params until we hit the variadic
		;param, which is wrong in this case. Varaidic functions take all params
		paramCount := callback.IsVariadic? 4 : Min(4, callback.MaxParams)

		accumulator := initialValue ?? arr[1]
		startOffset := IsSet(initialValue)? 0 : 1

		Loop(arr.Length - startOffset){
			index := A_Index + startOffset

			params := [accumulator, arr[index], index, arr]
			params.Length := paramCount					;Cut off extras
			accumulator := callback.Call(params*)
		}

		return accumulator
	}
    
	/**
	 * Removes and returns the first element in an array
	 * @param {Array} arr the array to shift an element from 
	 */
	static Shift(arr) {
		return arr.RemoveAt(1)
	}

	/**
	 * Prepends elements onto an array
	 * @param {Array} arr the array to unshift the elements into
	 * @param {Any} vals 0 or more values to unshift into the array
	 */
	static Unshift(arr, vals*) {
		arr.InsertAt(1, vals*)
	}

	/**
	 * Returns a truthy value if `arr` and `other` are the same length and if for index in
	 * the arrays, arr[i] == other[i] according to `equalityComparer`
	 * 
	 * @param {Array<Any>} arr The first array to compare
	 * @param {Array<Any>} other The second array to compare
	 * @param {Func(Any, Any) => Boolean} equalityComparer A function that takes in two
	 * 		elements and returns a truthy value if they are equal and a falsy value if
	 * 		they are not. If unset, the default comparer is:
	 * 
	 * 			(left, right) => left == right
	 */
	static SequenceEquals(arr, other, equalityComparer?) {
		equalityComparer := equalityComparer ?? (left, right) => left == right
		if(!HasMethod(equalityComparer, , 2))
			throw MethodError(Format("Object of type {1} is not callable with two arguments", Type(equalityComparer)))

		if(arr.length != other.length)
			return false

		Loop(arr.Length){
			if(!equalityComparer.Call(arr[A_Index], other[A_Index]))
				return false
		}

		return true
	}

	/**
	 * Fills some or all indices of an array with a particular value
	 * 
	 * @param {Array} arr array to fill 
	 * @param {Any} val value to full `arr` with 
	 * @param {Integer} start the index at which to start filling `arr` 
	 * @param {Integer} end the index at which to stop filling `arr` 
	 */
	static Fill(arr, val, start?, end?) {
		start := Integer(start ?? 1)
		end := Integer(end ?? (start < 0? -1 : arr.length))

		if(end < start){
			throw ValueError("Invalid range - end must refer to an index after start", -2, start . " to " . end)
		}

		Loop(Abs(end - start) + 1){
			i := start + (A_Index - 1)
			arr[i] := val
		}
	}
}