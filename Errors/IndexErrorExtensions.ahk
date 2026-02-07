#Requires AutoHotkey v2.0

/**
 * Holds extension methods for [IndexErrors](https://www.autohotkey.com/docs/v2/lib/Error.htm#IndexError)
 */
class IndexErrorExtensions {

    static __New() {
        IndexError.DefineProp("ThrowIfOutOfRange", { Call: IndexErrorExtensions.ThrowIfOutOfRange })
        IndexError.DefineProp("ThrowIfNotKey", { Call: IndexErrorExtensions.ThrowIfNotKey })
    }

    /**
     * Throws an IndexError if `value` is less than `min` or greater than `max`
     * 
     * @param {Number} value The value to check
     * @param {Number} min The minimum allowable value (inclusive)
     * @param {Number} max The maximum allowable value (inclusive)
     * @param {Integer} stackLevel Stack level at which to throw the error (default: -2)
     */
    static ThrowIfOutOfRange(value, min, max, stackLevel := -2) {
        if(value < min || value > max){
            msg := Format("Index out of range ({1} - {2})", min, max)
            throw IndexError(msg, stackLevel, value)
        }
    }

    /**
     * Throws an IndexError if `forMap.Has(value)` returns false
     */
    static ThrowIfNotKey(value, forMap, stackLevel := -2) {
        if(!forMap.Has(value)) {
            throw IndexError(Type(forMap) " has no such key", stackLevel, value)
        }
    }
}