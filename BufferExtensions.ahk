#Requires AutoHotkey v2.0

#Include <AhkWin32Projection\Windows\Win32\Security\Cryptography\Apis>
#Include <AhkWin32Projection\Windows\Win32\Security\Cryptography\BCRYPT_HASH_HANDLE>
#Include <AhkWin32Projection\Guid>

#DllLoad bcrypt.dll

/**
 * Holds extension methods for Buffers
 */
class BufferExtensions {
    static __New() {
        Buffer.Prototype.DefineProp("HexDump", { Call: (self) => BufferExtensions._CryptToString(self, 0x0000000b) })
        Buffer.Prototype.DefineProp("Fill", { Call: (self, byte) => BufferExtensions.Fill(self, byte) })
        Buffer.Prototype.DefineProp("Zero", { Call: (self) => BufferExtensions.Fill(self, 0) })
        Buffer.Prototype.DefineProp("CopyTo", { Call: (self, dest, length?) => BufferExtensions.CopyTo(self, dest, length?) })

        Buffer.Prototype.DefineProp("CompareTo", { Call: (self, other, length?) => BufferExtensions.CompareTo(self, other, length?) })
        Buffer.Prototype.DefineProp("MemoryEquals", { Call: (self, other) => BufferExtensions.CompareTo(self, other) == self.Size })

        Buffer.Prototype.DefineProp("ToHex", { Call: (self, flags?) => BufferExtensions._CryptToString(self, 0xC, flags?) })
        Buffer.Prototype.DefineProp("ToBase64", { Call: (self, flags?) => BufferExtensions._CryptToString(self, 1, flags?) })
        Buffer.Prototype.DefineProp("ToBase64URI", { Call: (self, flags?) => BufferExtensions._CryptToString(self, 0x0000000d, flags?) })

        Buffer.Prototype.DefineProp("Hash", { Call: (self, alg?) => BufferExtensions.Hash(self, alg?) })
        Buffer.Prototype.DefineProp("UUIDv5", { Call: (self, alg?) => BufferExtensions.UUIDv5(self) })

        ; CRYPT_STRING_HEX_ANY
        Buffer.DefineProp("FromHex", { Call: (self, str) => BufferExtensions._CryptFromString(str, 0x00000008)})
        ; CRYPT_STRING_BASE64_ANY
        Buffer.DefineProp("FromBase64", { Call: (self, str) => BufferExtensions._CryptFromString(str, 6)})
        Buffer.DefineProp("FromBinaryString", { Call: (self, str) => BufferExtensions._CryptFromString(str, 0x00000002)})

        Buffer.DefineProp("Random", { Call: (self, length) => BufferExtensions._Random(length)})
        Buffer.DefineProp("FromString", { Call: (self, str, encoding?) => BufferExtensions.FromString(str, encoding?)})

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

    /**
     * Wrapper around `CryptBinaryToStringW` that allows encodes a buffer's contents as a string
     * @see https://learn.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptbinarytostringw
     *
     * @param {Buffer} buf the buffer to encode
     * @param {Integer} defaultFlags the default `flags` parameter of `CryptBinaryToStringW`
     * @param {Integer} addtlFlags optional flags; if provided, these are ORed with the default
     */
    static _CryptToString(buf, defaultFlags, addtlFlags := 0x0) {
        flags := defaultFlags | addtlFlags

        ; Query for length
        Cryptography.CryptBinaryToStringW(buf, buf.size, flags, 0, &pcchString := 0)

        strBuf := Buffer((pcchString + 1) * 2 , 0)
        Cryptography.CryptBinaryToStringW(buf, buf.size, flags, strBuf, &pcchString)

        ;MsgBox(strBuf, "StrBuf after crypt to string")
        return StrGet(strBuf, pcchString, "UTF-16")
    }

    /**
     * Wrapper around CryptStringToBinaryW that reads a string as some format (e.g. Base64) and returns it as a
     * Buffer of binary data.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptstringtobinaryw
     * 
     * @param {String} str the string to read 
     * @param {Integer} flags the `flags` parameter of `CryptBinaryToStringW` 
     * @param {Integer} bufLen The initial size of the buffer in bytes. If this isn't large enough, Win32 returns the 
     *          required size and it is overridden. Default: 256
     */
    static _CryptFromString(str, flags, bufLen := 256) {
        success := Cryptography.CryptStringToBinaryW(str, StrLen(str), flags, buf, &pcbBinary := bufLen, 0, 0)
        buf := Buffer(bufLen)

        if(success) {
            buf.size := pcbBinary
            return buf
        }
        else {
            if(A_LastError)
                throw OSError()
            return BufferExtensions._CryptFromString(str, flags, pcbBinary + 1)
        }
    }

    /**
     * Creates a buffer with random data
     * @see https://learn.microsoft.com/en-us/windows/win32/seccng/processprng
     * 
     * @param {Integer} length the number of bytes to generate
     */
    static _Random(length) {
        buf := Buffer(length)
        Cryptography.ProcessPrng(buf, length)
        return buf
    }

    /**
     * Hashes the data in a buffer using a user-supplied algorithm (default: SHA1)
     * 
     * @param {Buffer} buf the data to hash 
     * @param {String} algorithm the {@link https://learn.microsoft.com/en-us/windows/win32/SecCNG/cng-algorithm-identifiers CNG Algorithm Identifier}
     *          for the algorithm to use
     * @returns {Buffer} a buffer containing the hash. 
     */
    static Hash(buf, algorithm := "SHA1") {
        hAlg := BCRYPT_ALG_HANDLE()
        stat := Cryptography.BCryptOpenAlgorithmProvider(hAlg, algorithm, 0, 0)
        BufferExtensions.ThrowForNtStatus(stat)

        try {
            pbOut := BufferExtensions._CryptGetProperty(hAlg.value, "HashDigestLength")
            finalHash := Buffer(NumGet(pbOut, "uint"), 0)

            stat := Cryptography.BCryptHash(hAlg, 0, 0, buf.ptr, buf.Size, finalHash, finalHash.Size)
            BufferExtensions.ThrowForNtStatus(stat)

            return finalHash
        }
        finally {
            Cryptography.BCryptCloseAlgorithmProvider(hAlg, 0)
        }
    }

    static _CryptGetProperty(hObj, propName) {
        ; Query for required size
        Cryptography.BCryptGetProperty(hObj, propName, 0, 0, &pcbResult := 0, 0)

        ; Get the actual property
        propBuf := Buffer(pcbResult, 0)
        stat := Cryptography.BCryptGetProperty(hObj, propName, propBuf, propBuf.Size, &pcbResult, 0)
        BufferExtensions.ThrowForNtStatus(stat)

        return propBuf
    }

    /**
     * Returns a UUIDv5 hash of the data contained in a buffer as a String
     * TODO do namespace + name stuff ourselves
     * 
     * @param {Buffer} buf the buffer to hash 
     * @returns {Guid} the generated guid
     */
    static UUIDv5(buf) {
        ; Step 1 - Get a SHA1 hash
        shaHash := BufferExtensions.Hash(buf, "SHA1")

        ; Grab its first 16 bytes - Guid() with no args creates an empty struct
        uuid := Guid()
        BufferExtensions.CopyTo(shaHash, uuid.__buf, 16)

        ; Set version = 5 (upper nibble of byte 6)
        byte6 := NumGet(uuid.__buf, 6, "uchar")
        NumPut("uchar", (byte6 & 0x0F) | 0x50, uuid.__buf, 6)

        ; Set variant = RFC 4122 (bits 10xxxxxx at byte 8)
        byte8 := NumGet(uuid.__buf, 8, "uchar")
        NumPut("uchar", (byte8 & 0x3F) | 0x80, uuid.__buf, 8)

        return uuid
    }

    /**
     * Copies a string into a buffer using a user-provided encoding method, and returns it.
     * Note: This excludes the null terminator from the returned buffer.
     *
     * @param {String} str the string to put in the buffer
     * @param {String} encoding encoding to use (default: UTF-8)
     * @returns {Buffer} a buffer containing `str` encoded using `encoded` (without null terminator)
     */
    static FromString(str, encoding := "UTF-8") {
        ; StrPut returns length including null terminator
        fullLen := StrPut(str, encoding)
        tempBuf := Buffer(fullLen)
        StrPut(str, tempBuf, encoding)

        ; Create result buffer without null terminator
        result := Buffer(fullLen - 1)
        BufferExtensions.CopyTo(tempBuf, result, fullLen - 1)
        return result
    }
 
    ; See https://jpassing.com/2007/08/20/error-codes-win32-vs-hresult-vs-ntstatus/
    static ThrowForNtStatus(stat) {
        if(stat == 0)
            return

        throw OSError(Foundation.RtlNtStatusToDosError(stat))
    }
}