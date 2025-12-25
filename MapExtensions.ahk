#Requires AutoHotkey v2.0

/**
 * Holds extension methods for Maps
 */
class MapExtensions {
    static __New() {
        Map.DefineProp("CaseInsensitive", { Call: (self, pairs*) => MapExtensions.CreateCaseInsensitive(pairs*)})

        Map.Prototype.DefineProp("ToString", { Call: (self) => MapExtensions.MapToString(self) })
        Map.Prototype.DefineProp("ForEach", { Call: (self, callback) => MapExtensions.ForEach(self, callback) })
        Map.Prototype.DefineProp("Filter", { Call: (self, callback) => MapExtensions.Filter(self, callback) })
        Map.Prototype.DefineProp("All", { Call: (self, condition) => MapExtensions.All(self, condition)})
        Map.Prototype.DefineProp("Any", { Call: (self, condition?) => MapExtensions.Any(self, condition?)})
    }

    /**
     * Creates and optionaliy initializes a {@link https://www.autohotkey.com/docs/v2/lib/Map.htm#CaseSense case-insensitive}
     * Map.
     * 
     * @param {Array<Any>} pairs the starting values of the map. Must contain an even number of elements
     * @returns {Map<Any, Any>} a map with `CaseSense` = `Off` populated with the values from `pairs`
     */
    static CreateCaseInsensitive(pairs*) {
        if(Mod(pairs.length, 2) != 0)
            throw ValueError("Invalid starting state; list of key/value pairs must have an even number of elements")

        m := Map()
        m.CaseSense := "Off"

        Loop(pairs){
            m[A_Index] := m[++A_Index] ; Changing A_Index modifies outer loop
        }

        return m
    }

    /**
     * Produces a string representation of a Map
     * 
     * @param {Map} m the map to stringify
     * @returns {String} a string representation of `m` 
     */
    static MapToString(m) {
        str := "{"

        for(key, value in m) {
            str .= Format("{1}: {2}", ItemToString(key), ItemToString(value))

            if(A_Index < m.Count)
                str .= ", "
        }
        
        str .= "}"
        return str

        ItemToString(itm) {
            if(itm is String) {
                return Format('"{1}"', itm)
            }
            else if (itm is Primitive || HasMethod(itm, "ToString", 0)) {
                return String(itm)
            }
            else{
                return Type(itm)
            }
        }
    }

    /**
     * Calls `callback` for every value in `m`
     * @param {Map} m the map to iterate 
     * @param {Func(Any, Any) => Any} callback callback function to call
     */
    static ForEach(m, callback) {
        for(key, value in m) {
            callback.Call(key, value)
        }
    }

    /**
	 * Creates a new map populated with only the values of the input map for which `condition` returns
	 * a truthy value
     * 
     * @param {Map<Any, Any>} m The input map to get values from 
     * @param {Func(Any, Any) => Boolean} condition The condition to evaluate
     * @returns {Map<Any, Any} a new map populated with only the values of the input map which meet
     *          `condition`.
     */
    static Filter(m, condition) {
        out := Map()

        for(key, value in m){
            if(condition.Call(key, value))
                out[key] := value
        }

        return out
    }

    /**
     * Determines whether or not every key-value pair in the map meets some condition.
     * 
     * @param {Map<Any, Any>} m The input map to get values from 
     * @param {Func(Any, Any) => Boolean} condition The condition to evaluate
     * @returns {Boolean} 1 if every value in the input map meets `condition`, 0 if any do not
     */
    static All(m, condition) {
        for(key, value in m){
            if(!condition.Call(key, value))
                return false
        }

        return true
    }

    /**
     * Determines whether or not any key-value pair in the map meets some condition.
     * 
     * @param {Map<Any, Any>} m The input map to get values from 
     * @param {Func(Any, Any) => Boolean} condition The condition to evaluate
     * @returns {Boolean} 1 if any value in the input map meets `condition`, 0 if none do
     */
    static Any(m, condition?){
        condition := condition ?? (*) => true

        for(key, value in m){
            if(condition.Call(key, value))
                return true
        }

        return false
    }
}