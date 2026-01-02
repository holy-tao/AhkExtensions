#Requires AutoHotkey v2.0

#Include ./Errors/TypeErrorExtensions.ahk

/**
 * Holds extension methods for {@link https://www.autohotkey.com/docs/v2/lib/Class.htm Classes}
 */
class ClassExtensions {

    static __New() {
        Class.Prototype.DefineProp("Resolve", { Call: (self, classname) => ClassExtensions.Resolve(classname)})
    }

    /**
     * Resolves a potentially nested class name to the actual class.
     *      
     *      btnClass := Class.Resolve("Gui.Button")
     * @param {String} classname The dot-delimited class name
     * @returns {Class} The class named by `classname`
     */
    static Resolve(classname) {
        TypeError.ThrowIfNot(classname, String, -4)

        cls := ""
        for(part in StrSplit(classname, ".")) {
            cls := cls is Class ? cls.%part% : %part%
        }
        return cls
    }
}