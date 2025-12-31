#Requires AutoHotkey v2.0

/**
 * Holds extension methods for Buffers
 */
class BufferExtensions {
    static __New() {
        Buffer.Prototype.DefineProp("HexDump", { Call: (self) => BufferExtensions.HexDump(self) })
        Buffer.Prototype.DefineProp("Fill", { Call: (self, byte) => BufferExtensions.Fill(self, byte) })
        Buffer.Prototype.DefineProp("Zero", { Call: (self) => BufferExtensions.Fill(self, 0) })
        Buffer.Prototype.DefineProp("CopyTo", { Call: (self, dest, length?) => BufferExtensions.CopyTo(self, dest, length?) })

        Buffer.Prototype.DefineProp("CompareTo", { Call: (self, other, length?) => BufferExtensions.CompareTo(self, other, length?) })
        Buffer.Prototype.DefineProp("MemoryEquals", { Call: (self, other) => BufferExtensions.CompareTo(self, other) == self.Size })

        ; Allow access via __Item and __Enum - note indexing is 0-based
        Buffer.Prototype.DefineProp("__Item", {
            Get: (self, offset) => BufferExtensions._BufferGetIndex(self, offset),
            Set: (self, value, offset) => BufferExtensions._BufferSetIndex(self, offset, value)
        })
        Buffer.Prototype.DefineProp("__Enum", { Call: (self, numVars) => BufferExtensions.Enumerator(self, numVars) })
    }

    /**
     * Supports `__Item`
     */
    static _BufferGetIndex(buf, offset) {
        if(offset < 0 || offset >= buf.Size)
            throw IndexError("Offset out of range", -2, offset)
        return NumGet(buf, offset, "uchar")
    }

    /**
     * Supports `__Item`
     */
    static _BufferSetIndex(buf, offset, value) {
        if(offset < 0 || offset >= buf.Size)
            throw IndexError("Offset out of range", -2, offset)
        return NumPut("uchar", value, buf, offset & 0xFF)
    }

    /**
     * Supports `__Enum` for Buffers
     */
    class Enumerator {
        __New(source, numVars) {
            if(!(numVars == 1 || numVars == 2))
                throw ValueError("Too many enumeration variables; Buffers support 1 or 2", -2, numVars)

            this._numVars := numVars
            this._source := source
            this._offset := 0
        }

        Call(&out1, &out2 := 0) {
            if(this._offset >= this._source.Size)
                return false

            if(this._numVars == 2){
                 out1 := this._offset
                 out2 := NumGet(this._source, this._offset, "uchar")
            }
            else {
                out1 := NumGet(this._source, this._offset, "uchar")
            }

            this._offset++
            return true
        }
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
     * Fills a buffer with some byte
     * @param {Buffer} buf The buffer to fill
     * @param {Integer} byte The byte to fill `Buffer` with. If larger than a byte, it is truncated
     */
    static Fill(buf, byte) {
        DllCall("RtlFillMemory", "ptr", buf, "uint", buf.Size, "uint", byte & 0xFF)
    }

    /**
     * Copies some or all of a buffer to a destination buffer or pointer
     * @see {@link https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-rtlmovememory RtlMoveMemory macro (wdm.h) - Windows drivers | Microsoft Learn}
     * 
     * @param {Buffer} source The source buffer
     * @param {Buffer | Ptr} destination The destination. Can be a buffer or a raw pointer
     * @param {Integer} length The number of bytes from `source` to copy to `destination`. If unset, 
     *          all of `source` is copied 
     */
    static CopyTo(source, destination, length?) {
        length := length ?? source.Size
        if(length <= 0 || length > source.Size)
            throw ValueError("Length must be a positive number <= to source buffer size", -2, length)

        ; If destination is Buffer-like we can check its size
        if(destination.HasProp("Size") && length > destination.Size){
            throw MemoryError(Format("Cannot copy {1} bytes to a {2} of size {3}", 
                length, Type(destination), destination.Size), -2)
        }

        DllCall("RtlMoveMemory", "ptr", destination, "ptr", source, "uint", length)
    }

    /**
     * Compares compares `self` and `other` and returns the number of bytes that match until the first difference.
     * @param {Buffer} self The first buffer to compare
     * @param {Buffer | Integer} other The second buffer or a pointer to a memory location to compare
     * @param {Integer} length The number of bytes to compare. If unset, defaults to `self.Size`.
     * @returns {Integer} The number of bytes in the two blocks that match. If all bytes match up to `length`, 
     *          `length` is returned
     */
    static CompareTo(self, other, length?) {
        length := length ?? self.Size
        if(length <= 0 || length > self.Size)
            throw ValueError("Length must be a positive number <= to source buffer size", -2, length)

        return DllCall("RtlCompareMemory", "ptr", self, "ptr", other, "uint", length)
    }
}