#Requires AutoHotkey v2.0

/**
 * Holds extension methods for Buffers
 */
class BufferExtensions {
    static __New() {
        Buffer.Prototype.DefineProp("HexDump", { Call: (self) => BufferExtensions.HexDump(self) })
    }

    /**
     * Returns a formatted string representing the contents of the struct in hex, with the bytes' ASCII
     * representations (if printable) on the right. This dump is intended to be as human-readable as
     * possible
     * 
     * @param {Buffer} buf the buffer to hex dump
     * @returns {String} a formatted dump string 
     */
    static HexDump(buf){
        dump := "", asciiBuffer := ""
        dumpLength := buf.size + Mod(16 - Mod(buf.size, 16), 16)     ;Pad to 8 byte boundary
        VarSetStrCapacity(&dump, 70 * (dumpLength / 16))             ;Every row is 69 chars + newline (nice)

        Loop(dumpLength){
            if(A_Index > 1){
                if(Mod(A_Index - 1, 16) == 0){
                    ;Newline, unless we're on the first line
                    dump .= Format(" |{1}|`n", asciiBuffer)
                    asciiBuffer := ""
                }
                else if(Mod(A_Index - 1, 8) == 0){
                    dump .= " "
                }
            }
            
            if(A_Index <= buf.size){
                byte := NumGet(buf, A_Index - 1, "char") & 0xFF
                dump .= Format("{1:02X} ", byte)
                
                asciiBuffer .= (byte >= 32 && byte <= 126)? Chr(byte) : "."
            }
            else{
                asciiBuffer .= " "
                dump .= "-- "
            }
        }

        dump .= Format(" |{1}|`n", asciiBuffer)
        return dump
    }

    /**
     * 
     * @param {Buffer} buf 
     * @param {Integer} byte the byte to fill `Buffer` with 
     */
    static Fill(buf, byte) {
        if(byte & 0xFF != byte) {
            throw ValueError("Fill byte must actually be a byte", -1, byte)
        }
    }
}

;@Ahk2Exe-IgnoreBegin
if(A_ScriptName == "BufferExtensions.ahk") {
    testBuf := Buffer(8 * Random(1, 20))
    FileAppend(testBuf.HexDump(), "*")
}
;@Ahk2Exe-IgnoreEnd