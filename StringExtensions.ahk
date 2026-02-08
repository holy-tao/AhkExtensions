#Requires AutoHotkey v2.0.0

#Include .\Errors\TypeErrorExtensions.ahk

class StringExtensions {
    static __New() {
        StrDefineProp := Object.Prototype.DefineProp.Bind(String.Prototype)

        ; Builtins - most of these can redirect directly to the builtin. Syntax is identical to the builtin, but
        ; without the first argument
        StrDefineProp("Length", { Get: StrLen })
        StrDefineProp("Ptr", { Get: StrPtr })

        StrDefineProp("Split", { Call: StrSplit })
        StrDefineProp("Replace", { Call: StrReplace })
        StrDefineProp("RegExReplace", { Call: RegExReplace })
        StrDefineProp("Find", { Call: InStr })
        StrDefineProp("CompareTo", { Call: StrCompare })
        StrDefineProp("Sort", { Call: Sort })
        StrDefineProp("SubStr", { Call: SubStr })
        StrDefineProp("Ord", { Call: Ord })         ; https://www.autohotkey.com/docs/v2/lib/Ord.htm

        ; Is functions: https://www.autohotkey.com/docs/v2/lib/Is.htm#cat-string
        StrDefineProp("IsDigit", { Get: IsDigit })
        StrDefineProp("IsXDigit", { Get: IsXDigit })
        StrDefineProp("IsAlpha", { Get: IsAlpha })
        StrDefineProp("IsUpper", { Get: IsUpper })
        StrDefineProp("IsLower", { Get: IsLower })
        StrDefineProp("IsAlnum", { Get: IsAlnum })
        StrDefineProp("IsSpace", { Get: IsSpace })
        StrDefineProp("IsTime", { Get: IsTime })

        StrDefineProp("IsInteger", { Get: IsInteger })
        StrDefineProp("IsNumber", { Get: IsNumber })
        StrDefineProp("IsFloat", { Get: IsFloat })
        StrDefineProp("IsLabel", { Get: IsLabel })

        StrDefineProp("IsWhitespace", { Get: (self) => IsSpace(self) && (StrLen(self) > 0) })
        StrDefineProp("IsEmpty", { Get: (self) => StrLen(self) > 0 })

        ; Case: https://www.autohotkey.com/docs/v2/lib/StrLower.htm
        StrDefineProp("ToUpper", { Call: StrUpper })
        StrDefineProp("ToLower", { Call: StrLower })
        StrDefineProp("ToTitle", { Call: StrTitle })

        ; Trim: https://www.autohotkey.com/docs/v2/lib/Trim.htm
        StrDefineProp("Trim", { Call: Trim })
        StrDefineProp("LTrim", { Call: LTrim })
        StrDefineProp("RTrim", { Call: RTrim })

        ; https://www.autohotkey.com/docs/v2/lib/SplitPath.htm
        StrDefineProp("SplitPath", { Call: (self) => (SplitPath(self, &a1, &a2, &a3, &a4, &a5), {FileName: a1, Dir: a2, Ext: a3, NameNoExt: a4, Drive: a5}) })

        ; https://www.autohotkey.com/docs/v2/lib/RegExMatch.htm - returns match on success, empty string on failure
        ; Since objects are truthy, if("string".RegExMatch(regex)) works as expected
        StrDefineProp("RegExMatch", { Call: (self, needleRegEx, startingPos?) => (RegExMatch(self, needleRegEx , &match := 0, startingPos?) ? match : "")})

        StrDefineProp("Join", { Call: (self, strs*) => StringExtensions.Join(self, strs*) })
        StrDefineProp("Repeat", { Call: (self, count) => StringExtensions.Repeat(self, count) })
        StrDefineProp("Reverse", { Call: (self) => StringExtensions.Reverse(self) })
        StrDefineProp("LPad", { Call: (self, toLength, char?) => StringExtensions.LPad(self, toLength, char?) })
        StrDefineProp("RPad", { Call: (self, toLength, char?) => StringExtensions.RPad(self, toLength, char?) })
        StrDefineProp("Insert", { Call: (self, insertion, pos) => SubStr(self, 1, pos) . insertion . SubStr(self, pos + 1) })
        StrDefineProp("Remove", { Call: (self, start, length) => SubStr(self, 1, start - 1) . SubStr(self, start + length) })

        ; InStr aliases - all of these have the signature (string needle, bool caseSense)
        StrDefineProp("IndexOf", { Call: (self, needle, caseSense := true) => InStr(self, needle, caseSense, 1) })
        StrDefineProp("LastIndexOf", { Call: (self, needle, caseSense := true) => InStr(self, needle, caseSense, -1) })
        StrDefineProp("StartsWith", { Call: (self, needle, caseSense := true) => InStr(self, needle, caseSense) == 1 })
        StrDefineProp("EndsWith", { Call: (self, needle, caseSense := true) => (
            StrLen(self) >= StrLen(needle) && 
            InStr(self, needle, caseSense, -1) == StrLen(self) - StrLen(needle) + 1)
        })
        StrDefineProp("Contains", { Call: (self, needle, caseSense := true) => InStr(self, needle, caseSense) > 0 })

        StrDefineProp("__Item", { Get: (self, start, end := start) => SubStr(self, start, (end - start) + 1)})
        StrDefineProp("__Enum", { Call: (self, varCount) => StringExtensions.StrEnum(self, varCount)})

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