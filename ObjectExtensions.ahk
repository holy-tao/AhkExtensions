#Requires AutoHotkey v2.0

#Include MapExtensions.ahk
#Include ArrayExtensions.ahk

/**
 * Extension methods for base {@link https://www.autohotkey.com/docs/v2/lib/Object.htm Objects}.
 */
class ObjectExtensions {
    static __New() {
        Object.Prototype.DefineProp("ToString", { Call: (self) => ObjectExtensions.ObjToString(self) })

        Object.Prototype.DefineProp("AllProps", { Call: (self) => ObjectExtensions.GetAllProps(self) })
        Object.Prototype.DefineProp("AllValueProps", { Call: (self) => ObjectExtensions.GetAllValueProps(self) })
    }

    /**
     * Creates a string representation of the object. This is something like `Object { prop: val, prop2: val2 }
     * @param {Object} obj the object to convert 
     */
    static ObjToString(obj) {
        allProps := ObjectExtensions.GetAllValueProps(obj)
        if(allProps.Count == 0)
            return Type(obj)

        str := Type(obj) "{"
        for(name, value in allProps) {
            str .= Format("{1}: {2}", name, value is String ? '"' value '"' : String(value))
            if(A_Index < allProps.Count)
                str .= ", "
        }
        str .= "}"
        return str
    }

    /**
     * Returns the names and {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc descriptors} of
     * all properties available to `obj`, including properties inherited from base class(es)
     * 
     * @param {Object} obj The object to inspect
     * @returns {Map<String, Object>} A map of property names to property descriptors
     */
    static GetAllProps(obj) {
        props := Map()
        current := obj

        while(current.__Class != "Any") {
            for(key in current.OwnProps()) {
                if(!props.Has(key))
                    props[key] := current.GetOwnPropDesc(key)
            }

            current := current.base
        }

        return props
    }

    /**
     * Get the names and values of all value properties available to `obj`, including properties inherited from base 
     * class(es). These are properties which have no-argument getters. See {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#OwnProps `Object.OwnProps`}
     * for details on this.
     * 
     * @param {Object} obj The object to inspect
     * @returns {Map<String, Any>} The names and values of all value properties of `obj`. 
     */
    static GetAllValueProps(obj) {
        props := Map()
        current := obj

        while(current.__Class != "Any") {
            for(key, value in current.OwnProps()) {
                if(!props.Has(key))
                    props[key] := value
            }

            current := current.base
        }

        return props
    }
}