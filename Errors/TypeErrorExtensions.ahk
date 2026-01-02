#Requires AutoHotkey v2.0

/**
 * Holds extension methods for [TypeErrors](https://www.autohotkey.com/docs/v2/lib/Error.htm#TypeError)
 */
class TypeErrorExtensions {

    static __New() {
        TypeError.DefineProp("ThrowIfNot", { Call: TypeErrorExtensions.ThrowIfNot })
        TypeError.DefineProp("ThrowIfNotNumeric", { Call: TypeErrorExtensions.ThrowIfNotNumeric })
        TypeError.DefineProp("ThrowIfNotInteger", { Call: TypeErrorExtensions.ThrowIfNotInteger })
        TypeError.DefineProp("ThrowIfNotFloat", { Call: TypeErrorExtensions.ThrowIfNotFloat })
    }

    /**
     * Throws a TypeError if value is not an instance of one of the provided classes
     * 
     *      TypeError.ThrowIfNot("hello, world!", Integer, Gui, String, -3)
     */
    static ThrowIfNot(value, types*) {
        stackLevel := IsInteger(types[types.Length]) ? Integer(types.Pop()) : ""

        for(t in types) {
            if(value is t)
                return
        }

        ; TypeError - construct a pretty message
        typeList := ""
        for(t in types) {
            typeList .= t.Prototype.__Class
            if(A_Index < types.Length - 1){
                typeList .= ", "
            }
            else if(A_Index == types.Length - 1){
                if(types.Length >= 3)
                    typeList .= "," ; Oxford comma
                typeList .= " or "
            }
        }

        msg := Format("Expected a(n) {1}, but got a(n) {2}", typeList, type(value))
        throw TypeError(msg, stackLevel, value)
    }

    /**
     * Throws a TypeError if `str` is not {@link https://www.autohotkey.com/docs/v2/lib/Is.htm#number numeric}. Returns
     * the value as a pure number if it is numeric
     */
    static ThrowIfNotNumeric(str, stackLevel := -2) {
        if(!IsNumber(str))
            throw TypeError("Expected a Number or numeric String, but got a(n) " Type(str), stackLevel, str)

        return Number(str)
    }

    static ThrowIfNotInteger(str, stackLevel := -2) {
        if(!IsInteger(str))
            throw TypeError("Expected a Number or numeric String, but got a(n) " Type(str), stackLevel, str)

        return Integer(str)
    }

    static ThrowIfNotFloat(str, stackLevel := -2) {
        if(!IsFloat(str))
            throw TypeError("Expected a Number or numeric String, but got a(n) " Type(str), stackLevel, str)

        return Float(str)
    }
}