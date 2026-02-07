#Requires AutoHotkey v2.0

#Include ./YUnit/Assert.ahk

#Include ../BufferExtensions.ahk

class BufferExtensionTests {
    ItemSet_WithValidOffset_SetsByte() {
        buf := Buffer(4, 0)
        buf[0] := 0x42

        Assert.Equals(NumGet(buf, 0, "uchar"), 0x42)
        Assert.Equals(NumGet(buf, 1, "uchar"), 0)
        Assert.Equals(NumGet(buf, 2, "uchar"), 0)
        Assert.Equals(NumGet(buf, 3, "uchar"), 0)
    }

    ItemSet_WithInvalidIndex_ThrowsIndexError() {
        buf := Buffer(4, 0)

        Assert.Throws((*) => buf[-1] := 0x42, IndexError)
        Assert.Throws((*) => buf[4] := 0x42, IndexError)
    }

    ItemGet_withValidOffset_GetsByte() {
        buf := Buffer(4, 0)
        NumPut("uchar", 0x1, "uchar", 0x2, "uchar", 0x3, "uchar", 0x4, buf)

        Assert.Equals(buf[0], 0x1)
        Assert.Equals(buf[1], 0x2)
        Assert.Equals(buf[2], 0x3)
        Assert.Equals(buf[3], 0x4)
    }

    ItemGet_WithInvalidIndex_ThrowsIndexError() {
        buf := Buffer(4, 0)

        Assert.Throws((*) => buf[-1], IndexError)
        Assert.Throws((*) => buf[4], IndexError)
    }

    Fill_FillsBuffer() {
        buf := Buffer(4, 0)
        buf.Fill(0x42)

        Assert.Equals(NumGet(buf, 0, "uchar"), 0x42)
        Assert.Equals(NumGet(buf, 1, "uchar"), 0x42)
        Assert.Equals(NumGet(buf, 2, "uchar"), 0x42)
        Assert.Equals(NumGet(buf, 3, "uchar"), 0x42)
    }

    Zero_ZeroesMemory() {
        buf := Buffer(4, 0)
        NumPut("uchar", 0x1, "uchar", 0x2, "uchar", 0x3, "uchar", 0x4, buf)
        buf.Zero()

        Assert.Equals(NumGet(buf, 0, "uchar"), 0)
        Assert.Equals(NumGet(buf, 1, "uchar"), 0)
        Assert.Equals(NumGet(buf, 2, "uchar"), 0)
        Assert.Equals(NumGet(buf, 3, "uchar"), 0)
    }

    HexDump_DumpsHexValues() {
        buf := Buffer(16)
        Loop(buf.Size) {
            NumPut("uchar", +("0x" A_Index*2), buf, A_Index-1)
        }

        Assert.Equals(buf.HexDump(), '0000	02 04 06 08 10 12 14 16  18 20 22 24 26 28 30 32   ......... "$&(02`r`n')
    }

    Enum_WithOneVar_EnumeratesValues() {
        buf := Buffer(4, 0)
        NumPut("uchar", 0x1, "uchar", 0x2, "uchar", 0x3, "uchar", 0x4, buf)

        for(byte in buf){
            Assert.Equals(byte, +("0x" A_Index))
        }
    }

    Enum_WithTwoVars_EnumeratesValues() {
        buf := Buffer(4, 0)
        NumPut("uchar", 0x1, "uchar", 0x2, "uchar", 0x3, "uchar", 0x4, buf)

        for(offset, byte in buf){
            Assert.Equals(offset, A_Index - 1)
            Assert.Equals(byte, +("0x" A_Index))
        }
    }

    Enum_WithInvalidVarCount_ThrowsValueError() {
        buf := Buffer(4, 0)

        Assert.Throws(Loop3.Bind(buf), ValueError)

        Loop3(buf) {
            for(offset, byte, nonsense in buf) {

            }
        }
    }

    CopyTo_WithNoLength_CopiesWhileBuffer() {
        buf := Buffer(4, 0), buf2 := Buffer(4, 0)
        NumPut("uchar", 0x1, "uchar", 0x2, "uchar", 0x3, "uchar", 0x4, buf)
        buf.CopyTo(buf2)

        Assert.Equals(NumGet(buf2, 0, "uchar"), 0x1)
        Assert.Equals(NumGet(buf2, 1, "uchar"), 0x2)
        Assert.Equals(NumGet(buf2, 2, "uchar"), 0x3)
        Assert.Equals(NumGet(buf2, 3, "uchar"), 0x4)
    }

    CopyTo_WithRawPointer_CopiesMemory() {
        buf := Buffer(4, 0), buf2 := Buffer(4, 0)
        NumPut("uchar", 0x1, "uchar", 0x2, "uchar", 0x3, "uchar", 0x4, buf)
        buf.CopyTo(buf2.ptr)

        Assert.Equals(NumGet(buf2, 0, "uchar"), 0x1)
        Assert.Equals(NumGet(buf2, 1, "uchar"), 0x2)
        Assert.Equals(NumGet(buf2, 2, "uchar"), 0x3)
        Assert.Equals(NumGet(buf2, 3, "uchar"), 0x4)
    }

    CopyTo_WithLength_CopiesLength() {
        buf := Buffer(4, 0), buf2 := Buffer(4, 0)
        NumPut("uchar", 0x1, "uchar", 0x2, "uchar", 0x3, "uchar", 0x4, buf)
        buf.CopyTo(buf2, 2)

        Assert.Equals(NumGet(buf2, 0, "uchar"), 0x1)
        Assert.Equals(NumGet(buf2, 1, "uchar"), 0x2)
        Assert.Equals(NumGet(buf2, 2, "uchar"), 0)
        Assert.Equals(NumGet(buf2, 3, "uchar"), 0)
    }

    CopyTo_WithInvalidLength_ThrowsValueError() {
        buf := Buffer(4, 0), buf2 := Buffer(4, 0)

        Assert.Throws((*) => buf.CopyTo(buf2, 5), ValueError)
        Assert.Throws((*) => buf.CopyTo(buf2, -1), ValueError)
    }

    CompareTo_WithNoLength_ComparesMemory() {
        buf1 := Buffer(4, 0), buf2 := Buffer(4, 0)

        Assert.Equals(buf1.CompareTo(buf2), 4)
    }

    CompareTo_WithNoLengthAndDifference_ReturnsDifferenceOffset() {
        buf1 := Buffer(4, 0), buf2 := Buffer(4, 0)
        NumPut("uchar", 0x42, buf2, 2)

        Assert.Equals(buf1.CompareTo(buf2), 2)
    }

    CompareTo_WithLength_ComparesMemory() {
        buf1 := Buffer(4, 0), buf2 := Buffer(4, 0)
        NumPut("uchar", 0x42, buf2, 2)

        Assert.Equals(buf1.CompareTo(buf2, 2), 2)
    }

    CompareTo_WithInvalidLength_ThrowsValueError() {
        buf := Buffer(4, 0), buf2 := Buffer(4, 0)

        Assert.Throws((*) => buf.CompareTo(buf2, 5), ValueError)
        Assert.Throws((*) => buf.CompareTo(buf2, -1), ValueError)
    }

    MemoryEquals_WithEqualBuffers_ReturnsTrue() {
        buf1 := Buffer(4, 0), buf2 := Buffer(4, 0)
        Assert.Equals(buf1.MemoryEquals(buf2), true)
    }

    MemoryEquals_WithNonEqualBuffers_ReturnsTrue() {
        buf1 := Buffer(4, 0), buf2 := Buffer(4, 0)
        NumPut("uchar", 0x42, buf2, 2)
        Assert.Equals(buf1.MemoryEquals(buf2), false)
    }

    Hash_WithSHA256_ReturnsCorrectHash() {
        ; Test vector: "hello" -> SHA256
        buf := Buffer.FromString("hello")
        hash := buf.Hash("SHA256")
        expected := "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"

        Assert.Equals(hash.ToHex(0x40000000), expected)
    }

    Hash_WithSHA1_ReturnsCorrectHash() {
        ; Test vector: "hello" -> SHA1
        buf := Buffer.FromString("hello")
        hash := buf.Hash("SHA1")
        expected := "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d"

        Assert.Equals(hash.ToHex(0x40000000), expected)
    }

    Hash_WithMD5_ReturnsCorrectHash() {
        ; Test vector: "hello" -> MD5
        buf := Buffer.FromString("hello")
        hash := buf.Hash("MD5")
        expected := "5d41402abc4b2a76b9719d911017c592"

        Assert.Equals(hash.ToHex(0x40000000), expected)
    }

    Hash_WithEmptyBuffer_ReturnsCorrectHash() {
        ; Test vector: empty string -> SHA256
        buf := Buffer(0)
        hash := buf.Hash("SHA256")
        expected := "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        Assert.Equals(hash.ToHex(0x40000000), expected)
    }

    Hash_WithLongString_ReturnsCorrectHash() {
        ; Test vector: "The quick brown fox jumps over the lazy dog" -> SHA256
        buf := Buffer.FromString("The quick brown fox jumps over the lazy dog")
        hash := buf.Hash("SHA256")
        expected := "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"

        Assert.Equals(hash.ToHex(0x40000000), expected)
    }

    UUIDv5_GeneratesValidGuid() {
        buf := Buffer.FromString("test data")
        uuid := buf.UUIDv5()

        ; Verify it returns a Guid object
        Assert.IsType(uuid, Guid)
    }

    UUIDv5_HasCorrectVersionBits() {
        buf := Buffer.FromString("test data")
        uuid := buf.UUIDv5()

        FileAppend("UUID raw: " uuid.__buf.ToHex(0x40000000) "`n", "*")
        FileAppend("UUID formatted: " uuid.ToString() "`n", "*")

        ; Version should be 5 (upper nibble of byte 6 should be 0x5)
        versionByte := uuid.__buf[6]
        Assert.Equals(versionByte & 0xF0, 0x50)
    }

    UUIDv5_HasCorrectVariantBits() {
        buf := Buffer.FromString("test data")
        uuid := buf.UUIDv5()

        FileAppend("UUID raw: " uuid.__buf.ToHex(0x40000000) "`n", "*")
        FileAppend("UUID formatted: " uuid.ToString() "`n", "*")

        ; Variant should be RFC 4122 (bits 10xxxxxx at byte 8)
        variantByte := uuid.__buf[8]
        Assert.Equals(variantByte & 0xC0, 0x80)
    }

    UUIDv5_IsDeterministic() {
        ; Same input should always produce the same UUID
        buf1 := Buffer.FromString("deterministic test")
        buf2 := Buffer.FromString("deterministic test")

        uuid1 := buf1.UUIDv5()
        uuid2 := buf2.UUIDv5()

        Assert.Equals(uuid1.ToString(), uuid2.ToString())
    }

    UUIDv5_DifferentInputsProduceDifferentUUIDs() {
        buf1 := Buffer.FromString("test1")
        buf2 := Buffer.FromString("test2")

        uuid1 := buf1.UUIDv5()
        uuid2 := buf2.UUIDv5()

        Assert.NotEquals(uuid1.ToString(), uuid2.ToString())
    }
}