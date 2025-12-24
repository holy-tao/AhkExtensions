#Requires AutoHotkey v2.0

/**
 * Holds extension methods for Maps
 */
class MapExtensions {
    static __New() {
        Map.Prototype.DefineProp("ToString", { Call: (self) => MapExtensions.MapToString(self) })
        Map.Prototype.DefineProp("ForEach", { Call: (self, callback) => MapExtensions.ForEach(self, callback) })
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
            callback.Call(m)
        }
    }
}