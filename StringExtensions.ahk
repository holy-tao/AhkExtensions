#Requires AutoHotkey v2.0.0

#Include .\Errors\TypeErrorExtensions.ahk

class StringExtensions {
    static __New() {
        String.Prototype.DefineProp := Object.Prototype.DefineProp

        ; Builtins - most of these can redirect directly to the builtin. Syntax is identical to the builtin, but
        ; without the first argument
        String.Prototype.DefineProp("Length", { Get: StrLen })
        String.Prototype.DefineProp("Ptr", { Get: StrPtr })

        String.Prototype.DefineProp("Split", { Call: StrSplit })
        String.Prototype.DefineProp("Replace", { Call: StrReplace })
        String.Prototype.DefineProp("RegExReplace", { Call: RegExReplace })
        String.Prototype.DefineProp("Find", { Call: InStr })
        String.Prototype.DefineProp("CompareTo", { Call: StrCompare })
        String.Prototype.DefineProp("Sort", { Call: Sort })
        String.Prototype.DefineProp("SubStr", { Call: SubStr })
        String.Prototype.DefineProp("Ord", { Call: Ord })         ; https://www.autohotkey.com/docs/v2/lib/Ord.htm

        ; Is functions: https://www.autohotkey.com/docs/v2/lib/Is.htm#cat-string
        String.Prototype.DefineProp("IsDigit", { Get: IsDigit })
        String.Prototype.DefineProp("IsXDigit", { Get: IsXDigit })
        String.Prototype.DefineProp("IsAlpha", { Get: IsAlpha })
        String.Prototype.DefineProp("IsUpper", { Get: IsUpper })
        String.Prototype.DefineProp("IsLower", { Get: IsLower })
        String.Prototype.DefineProp("IsAlnum", { Get: IsAlnum })
        String.Prototype.DefineProp("IsSpace", { Get: IsSpace })
        String.Prototype.DefineProp("IsTime", { Get: IsTime })

        String.Prototype.DefineProp("IsInteger", { Get: IsInteger })
        String.Prototype.DefineProp("IsNumber", { Get: IsNumber })
        String.Prototype.DefineProp("IsFloat", { Get: IsFloat })
        String.Prototype.DefineProp("IsLabel", { Get: IsLabel })

        String.Prototype.DefineProp("IsWhitespace", { Get: (self) => IsSpace(self) && (StrLen(self) > 0) })
        String.Prototype.DefineProp("IsEmpty", { Get: (self) => StrLen(self) > 0 })

        ; Case: https://www.autohotkey.com/docs/v2/lib/StrLower.htm
        String.Prototype.DefineProp("ToUpper", { Call: StrUpper })
        String.Prototype.DefineProp("ToLower", { Call: StrLower })
        String.Prototype.DefineProp("ToTitle", { Call: StrTitle })

        ; Trim: https://www.autohotkey.com/docs/v2/lib/Trim.htm
        String.Prototype.DefineProp("Trim", { Call: Trim })
        String.Prototype.DefineProp("LTrim", { Call: LTrim })
        String.Prototype.DefineProp("RTrim", { Call: RTrim })

        ; https://www.autohotkey.com/docs/v2/lib/SplitPath.htm
        String.Prototype.DefineProp("SplitPath", { Call: (self) => (SplitPath(self, &a1, &a2, &a3, &a4, &a5), {FileName: a1, Dir: a2, Ext: a3, NameNoExt: a4, Drive: a5}) })

        ; https://www.autohotkey.com/docs/v2/lib/RegExMatch.htm - returns match on success, empty string on failure
        ; Since objects are truthy, if("string".RegExMatch(regex)) works as expected
        String.Prototype.DefineProp("RegExMatch", { Call: (self, needleRegEx, startingPos?) => (RegExMatch(self, needleRegEx , &match := 0, startingPos?) ? match : "")})

        String.Prototype.DefineProp("Join", { Call: (self, strs*) => StringExtensions.Join(self, strs*) })
        String.Prototype.DefineProp("Repeat", { Call: (self, count) => StringExtensions.Repeat(self, count) })
        String.Prototype.DefineProp("Reverse", { Call: (self) => StringExtensions.Reverse(self) })
        String.Prototype.DefineProp("LPad", { Call: (self, toLength, char?) => StringExtensions.LPad(self, toLength, char?) })
        String.Prototype.DefineProp("RPad", { Call: (self, toLength, char?) => StringExtensions.RPad(self, toLength, char?) })
        String.Prototype.DefineProp("Insert", { Call: (self, insertion, pos) => SubStr(self, 1, pos) . insertion . SubStr(self, pos + 1) })
        String.Prototype.DefineProp("Remove", { Call: (self, start, length) => SubStr(self, 1, start - 1) . SubStr(self, start + length) })

        ; InStr aliases - all of these have the signature (string needle, bool caseSense)
        String.Prototype.DefineProp("IndexOf", { Call: (self, needle, caseSense := true) => InStr(self, needle, caseSense, 1) })
        String.Prototype.DefineProp("LastIndexOf", { Call: (self, needle, caseSense := true) => InStr(self, needle, caseSense, -1) })
        String.Prototype.DefineProp("StartsWith", { Call: (self, needle, caseSense := true) => InStr(self, needle, caseSense) == 1 })
        String.Prototype.DefineProp("EndsWith", { Call: (self, needle, caseSense := true) => (
            StrLen(self) >= StrLen(needle) && 
            InStr(self, needle, caseSense, -1) == StrLen(self) - StrLen(needle) + 1)
        })
        String.Prototype.DefineProp("Contains", { Call: (self, needle, caseSense := true) => InStr(self, needle, caseSense) > 0 })

        String.Prototype.DefineProp("__Item", { Get: (self, start, end := start) => SubStr(self, start, (end - start) + 1)})
        String.Prototype.DefineProp("__Enum", { Call: (self, varCount) => StringExtensions.StrEnum(self, varCount)})

        ; Static variants
        String.DefineProp("Join", { Call: (self, delimiter, strs*) => StringExtensions.Join(delimiter, strs*) })
        String.DefineProp("Repeat", { Call: (self, str, count) => StringExtensions.Repeat(str, count) })
    }

    /**
     * Returns an enumerator for a String, supports String.__Enum.
     * 
     * Ripped from https://github.com/Descolada/AHK-v2-libraries/blob/77737ca744359818a15f86c218fbc3f6aa352aff/Lib/String.ahk#L88
     * @param {String} str the string to enumerate 
     * @param {Integer} varCount the number of variables (1 for just char, 2 for index and char) 
     */
	static StrEnum(str, varCount) {
		pos := 0, len := StrLen(str)
		EnumElements(&char) {
			char := StrGet(StrPtr(str) + 2*pos, 1)
			return ++pos <= len
		}
		
		EnumIndexAndElements(&index, &char) {
			char := StrGet(StrPtr(str) + 2*pos, 1), index := ++pos
			return pos <= len
		}

		return varCount = 1 ? EnumElements : EnumIndexAndElements
	}

    /**
     * Joins strings with `delimiter`.
     * @param {String} delimiter The delimiter 
     * @param {String} strs Zero or more strings to join with `delimiter` 
     */
    static Join(delimiter, strs*) {
        outStr := ""
        for(str in strs) {
            TypeError.ThrowIfNot(str, String, -4)

            outStr .= str
            if(A_Index < strs.Length)
                outStr .= delimiter
        }

        return outStr
    }

    /**
     * Returns a new string of a specified length in which the beginning of the current string is padded with 
     * spaces or with a specified Unicode character.
     * @param {String} str The string to pad
     * @param {String} toLength 
     * @param {String} char The character(s) to pad the string with
     */
    static LPad(str, toLength, char := A_Space) {
        TypeError.ThrowIfNot(char, String, -4)

        if(StrLen(char) != 1)
            throw ValueError("Invalid padding character", -2, char)

        return StringExtensions.Repeat(char, Max(toLength - StrLen(str), 0)) . str
    }

    /**
     * Returns a new string of a specified length in which the end of the current string is padded with 
     * spaces or with a specified Unicode character.
     * @param {String} str The string to pad
     * @param {String} toLength 
     * @param {String} char The character(s) to pad the string with
     */
    static RPad(str, toLength, char := A_Space) {
        TypeError.ThrowIfNot(char, String, -4)

        if(StrLen(char) != 1)
            throw ValueError("Invalid padding character", -2, char)

        return str . StringExtensions.Repeat(char, Max(toLength - StrLen(str), 0))
    }

    /**
     * Concatenates `str` with itself `count` times
     * @param {String} str The string to repeat
     * @param {Integer} count The number of times to repeat `str` 
     */
    static Repeat(str, count) {
        TypeError.ThrowIfNotInteger(count)
        if(count < 0)
            throw ValueError("Count cannot be negative", -2, count)

        outStr := ""
        Loop(count)
            outStr .= str
        return outStr
    }

    /**
     * Reverses a string, returns the reversed string
     * @param {String} str The string to reverse 
     */
    static Reverse(str) {
        reversed := ""
        Loop(StrLen(str))
            reversed .= SubStr(str, -A_Index, 1)
        return reversed
    }
}