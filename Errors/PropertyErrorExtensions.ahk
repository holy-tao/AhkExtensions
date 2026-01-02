#Requires AutoHotkey v2.0

/**
 * Holds extension methods for [PropertyErrors](https://www.autohotkey.com/docs/v2/lib/Error.htm#MemberError)
 */
class PropertyErrorExtensions {

    static __New() {
        PropertyError.DefineProp("ThrowIfDoesNotHaveProperty", { Call: PropertyErrorExtensions.ThrowIfDoesNotHaveProperty })
        PropertyError.DefineProp("ThrowIfDoesNotHaveOwnProp", { Call: PropertyErrorExtensions.ThrowIfDoesNotHaveOwnProp })
        PropertyError.DefineProp("ThrowReadOnly", { Call: PropertyErrorExtensions.ThrowReadOnly })
    }

    /**
     * For duck-typing, throws an error if `HasProp(value, propName)` returns false
     */
    static ThrowIfDoesNotHaveProperty(value, propName, stackLevel := -2) {
        if(!HasProp(value, propName)) {
            msg := Format("Value of type {1} has no property named `"{2}`"", Type(value), propName)
            throw PropertyError(msg, stackLevel, value)
        }
    }

    /**
     * For duck-typing, throws an error if `ObjHasOwnProp(value, propName)` returns false
     */
    static ThrowIfDoesNotHaveOwnProp(value, propName, stackLevel := -2) {
        if(!ObjHasOwnProp(value, propName)) {
            msg := Format("Value of type {1} has no property named `"{2}`"", Type(value), propName)
            throw PropertyError(msg, stackLevel, value)
        }
    }

    static ThrowReadOnly(propName, stackLevel := -2) {
        throw PropertyError("This property is read-only", stackLevel, propName)
    }
}