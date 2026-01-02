#Requires AutoHotkey v2.0

/**
 * Holds extension methods for [PropertyErrors](https://www.autohotkey.com/docs/v2/lib/Error.htm#MemberError)
 */
class MethodErrorExtensions {
    static __New() {
        MethodErrorExtensions.DefineProp("ThrowIfDoesNotHaveMethod", { Call: MethodErrorExtensions.ThrowIfDoesNotHaveMethod })
        MethodErrorExtensions.DefineProp("ThrowNotImplemented", { Call: MethodErrorExtensions.ThrowNotImplemented })
        MethodErrorExtensions.DefineProp("ThrowAbstract", { Call: MethodErrorExtensions.ThrowAbstract })
        MethodErrorExtensions.DefineProp("ThrowDeprecated", { Call: MethodErrorExtensions.ThrowDeprecated })
    }

    /**
     * For duck-typing, thows an error if `HasMethod(value, methodName, paramCount)` returns false
     */
    static ThrowIfDoesNotHaveMethod(value, methodName, paramCount := "", stackLevel := -2) {
        if(!HasMethod(value, methodName, paramCount)){
            msg := Format("Value of type {1} has no method named `"{2}`"", Type(value), methodName)
            if(paramCount != "")
                msg .= Format(" that can accept {1} arguments", paramCount)

            throw MethodError(msg, stackLevel, value)
        }
    }

    static ThrowNotImplemented(stackLevel := -2) {
        throw NotImplementedError("Not implemented", stackLevel)
    }

    static ThrowAbstract(stackLevel := -2) {
        throw MethodError("This method is abstract and must be called on a class extending this one", stackLevel)
    }

    static ThrowDeprecated(alternative, stackLevel := -2) {
        throw MethodError("This method is deprecated. Use " alternative " instead", stackLevel)
    }
}

class NotImplementedError extends MethodError {
    ; stub, just for type checking / logging
}