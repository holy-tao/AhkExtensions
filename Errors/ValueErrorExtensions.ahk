#Requires AutoHotkey v2.0

/**
 * Holds extension methods for [ValueErrors](https://www.autohotkey.com/docs/v2/lib/Error.htm#ValueError)
 * 
 *      ValueError.ThrowIfNegative(argument, "argument")
 */
class ValueErrorExtensions {

    static __New() {
        ValueError.DefineProp("ThrowIfNegative", { Call: ValueErrorExtensions.ThrowIfNegative })
        ValueError.DefineProp("ThrowIfZero", { Call: ValueErrorExtensions.ThrowIfZero })
        ValueError.DefineProp("ThrowIfZeroOrNegative", { Call: ValueErrorExtensions.ThrowIfZeroOrNegative })
        ValueError.DefineProp("ThrowIfEqual", { Call: ValueErrorExtensions.ThrowIfEqual })
        ValueError.DefineProp("ThrowIfNotEqual", { Call: ValueErrorExtensions.ThrowIfNotEqual })
        ValueError.DefineProp("ThrowIfGreaterThan", { Call: ValueErrorExtensions.ThrowIfGreaterThan })
        ValueError.DefineProp("ThrowIfGreaterThanOrEqualTo", { Call: ValueErrorExtensions.ThrowIfGreaterThanOrEqualTo })
        ValueError.DefineProp("ThrowIfLessThan", { Call: ValueErrorExtensions.ThrowIfLessThan })
        ValueError.DefineProp("ThrowIfLessThanOrEqualTo", { Call: ValueErrorExtensions.ThrowIfLessThanOrEqualTo })
        ValueError.DefineProp("ThrowIfStringIsEmpty", { Call: ValueErrorExtensions.ThrowIfStringIsEmpty })
        ValueError.DefineProp("ThrowIfOutOfRange", { Call: ValueErrorExtensions.ThrowIfOutOfRange })
    }

    static ThrowIfNegative(value, argName, stackLevel := -2) {
        if(+value < 0)
            throw ValueError(argName " must not be negative", stackLevel, value)
    }

    static ThrowIfZero(value, argName, stackLevel := -2) {
        if(+value == 0)
            throw ValueError(argName " must not be zero", stackLevel, value)
    }

    static ThrowIfZeroOrNegative(value, argName, stackLevel := -2) {
        if(+value <= 0)
            throw ValueError(argName " must be positive", stackLevel, value)
    }
    
    static ThrowIfPositive(value, argName, stackLevel := -2) {
        if(+value > 0)
            throw ValueError(argName " must not be positive", stackLevel, value)
    }

    static ThrowIfEqual(value, expected, argName, stackLevel := -2) {
        if(value == expected) {
            msg := Format("{1} cannot equal {2}", argName, expected)
            throw ValueError(msg, stackLevel, value)
        }
    }

    static ThrowIfNotEqual(value, expected, argName, stackLevel := -2) {
        if(value != expected) {
            msg := Format("{1} must equal {2}", argName, expected)
            throw ValueError(msg, stackLevel, value)
        }
    }

    static ThrowIfGreaterThan(value, threshold, argName, stackLevel := -2) {
        if(+value > threshold){
            throw ValueError(argName " cannot be greater than " threshold, stackLevel, value)
        }
    }

    static ThrowIfGreaterThanOrEqualTo(value, threshold, argName, stackLevel := -2) {
        if(+value >= threshold){
            throw ValueError(argName " cannot be greater than or equal to " threshold, stackLevel, value)
        }
    }

    static ThrowIfLessThan(value, threshold, argName, stackLevel := -2) {
        if(+value < threshold){
            throw ValueError(argName " cannot be less than " threshold, stackLevel, value)
        }
    }

    static ThrowIfLessThanOrEqualTo(value, threshold, argName, stackLevel := -2) {
        if(+value > threshold){
            throw ValueError(argName " cannot be greater than " threshold, stackLevel, value)
        }
    }

    static ThrowIfStringIsEmpty(str, argName, stackLevel := -2) {
        if(IsSpace(str))
            throw ValueError(argName " must not be empty or whitespace", stackLevel, '"' str '"')
    }

    /**
     * Throws a ValueError if `value` is less than `min` or greater than `max`
     * 
     * @param {Number} value The value to check
     * @param {Number} min The minimum allowable value (inclusive)
     * @param {Number} max The maximum allowable value (inclusive)
     * @param {Integer} stackLevel Stack level at which to throw the error (default: -2)
     */
    static ThrowIfOutOfRange(value, min, max, argName, stackLevel := -2) {
        if(value < min || value > max){
            msg := Format(argName " out of range ({1} - {2})", min, max)
            throw IndexError(msg, stackLevel, value)
        }
    }
}

/**
 * An error for when a String or other value which must follow a specific pattern is improperly formatted
 */
class FormatError extends ValueError {

    /**
     * Throws a `FormatError` if `val` does not match a regex pattern
     * 
     * @param {String} val the value to check 
     * @param {String} pattern the pattern it must match 
     * @param {Integer} stackLevel Stack level at which to throw the error (default: -2)
     * @returns {RegExMatchInfo} if `val` matches `pattern`, returns the `RegExMatchInfo`
     */
    static ThrowIfDoesNotMatch(val, pattern, stackLevel := -2) {
        if(!RegExMatch(val, pattern, &info := "")) {
            throw FormatError("Value is improperly formatted", stackLevel, val)
        }

        return info
    }
}