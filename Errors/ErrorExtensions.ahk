#Requires AutoHotkey v2.0

/**
 * Holds extension methods for [Errors](https://www.autohotkey.com/docs/v2/lib/Error.htm). 
 * 
 * In addition to holding extension methods, including this class gives all classes extending `Error` and `Inner` 
 * property that allows them to be thrown as a result of other Errors. This is printed in `Format()` and `ToString`
 * along with the outer error if it is not empty (which it is by default)
 */
class ErrorExtensions {

    static __New() {
        Error.DefineProp("ThrowIf", {Call: (args*) => ErrorExtensions.ThrowIf(args*) })

        Error.Prototype.DefineProp("Inner", {Value: "" })
        Error.Prototype.DefineProp("Format", {Call: (self) => ErrorExtensions.Format(self) })
        Error.Prototype.DefineProp("ToString", {Call: (self) => ErrorExtensions.Format(self) })
        Error.Prototype.DefineProp("GetContext", {Call: (self, lines?) => ErrorExtensions.GetContext(self, lines?) })
    }

    /**
     * Throws an Error of the type of the class on which this method is called if `condition` is truthy
     * 
     *      TimeoutError.ThrowIf(elapsed > timeout, "Request timed out", request)
     * 
     * @param {Error} self A class extending Error (possibly error) 
     * @param {Boolean} condition The condition which should not be fulfilled 
     * @param {String} message The Error's message
     * @param {String} extra The Error's extra
     * @param {String} stackLevel The stack level to throw at (default: -2)
     */
    static ThrowIf(self, condition, message, extra := "", stackLevel := -2) {
        if(condition)
            throw self.Call(message, stackLevel, extra)
    }

    /**
     * Formats an error for nice printing to the console or a text file. Used for `ToString` as well.
     */
    static Format(self) {
        str := Format("{1}: {2}", Type(self), self.Message)
        if(self.Extra != "")
            str .= " (" self.Extra ")"
        str .= "`n    "
        str .= StrReplace(self.Stack, "`n", "`n    ")
        
        if(self.HasProp("Inner") && self.Inner is Error) {
            str := RTrim(str)
            str .= "Caused by:`n"
            str .= self.Inner.Format()
        }

        return Trim(str)
    }

    /**
     * When called in an uncompiled script, returns a nicely formatted string containing the lines of source 
     * code immediately surrounding `self.line`. Intended for use in e.g. ci/cd pipelines, where the error
     * dialog is not accessible.
     * 
     * @param {Error} self The error to get context for 
     * @param {Integer} lines The number of lines on either side of the error to read in
     * @returns {String} A nice printout of the soure code around where the error was thrown
     */
    static GetContext(self, lines := 2) {
        ; TODO it is possible to extract uncompressed scripts from compiled .exes
        if(A_IsCompiled)
            return "Context not available for compiled scripts"

        ctxFile := FileOpen(self.File, "r")
        fileLine := 0
        Loop(Max(self.Line - lines - 1, 0)){
            ctxFile.ReadLine()
            fileLine++
        }

        padWidth := StrLen(String(fileLine + (2 * lines) + 1))
        fmtString := "{1:" padWidth "} {2} | {3}`n"

        ; Create the first delimiter
        Loop(padWidth + 2)
           context .= "-"
        SplitPath(self.File, &fileName := "")
        context .= " " fileName " "
        while(StrLen(context) < 80)
           context .= "-"
        context .= "`n"

        ; Read lines above where error was thrown
        Loop(lines) {
            context .= Format(fmtString, ++fileLine, " ", ctxFile.ReadLine())
        }
        
        ; Error was thrown here
        context .= Format(fmtString, ++fileLine, ">", errLine := ctxFile.ReadLine())

        ; Read lines below thrower location
        Loop(lines) {
            if(ctxFile.AtEOF) {
                context .= Format("{1:-" padWidth "}   |`n", "EOF")
                break
            }
            context .= Format(fmtString, ++fileLine, " ", ctxFile.ReadLine())
        }
        context .= "--------------------------------------------------------------------------------`n"

        return context
    }
}