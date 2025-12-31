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

        Assert.Equals(buf.HexDump(), '02 04 06 08 10 12 14 16  18 20 22 24 26 28 30 32  |......... "$&(02|`n')
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
}