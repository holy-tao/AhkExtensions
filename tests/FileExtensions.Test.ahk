#Requires AutoHotkey v2.0

#Include ./YUnit/Assert.ahk
#Include ./YUnit/Yunit.ahk
#Include ./YUnit/Stdout.ahk

#Include ../FileExtensions.ahk

class FileExtensionTests {

    CreationTime_Matches() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.Equals(testFile.GetCreationTime(), FileGetTime(A_ScriptFullPath, "C"))
    }

    LastAccessTime_Matches() {
        testFile := FileOpen(A_ScriptFullPath, "r")

        ; Allow for a 3 second margin of error, as code editors access files in unpredictable ways
        Yunit.Assert(Abs(DateDiff(testFile.GetLastAccessTime(), FileGetTime(A_ScriptFullPath, "A"), "S")) <= 3)
        ; Assert.Equals(testFile.GetLastAccessTime(), FileGetTime(A_ScriptFullPath, "A"))
    }

    LastWriteTime_Matches() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.Equals(testFile.GetLastWriteTime(), FileGetTime(A_ScriptFullPath, "M"))
    }

    AttribString_Matches() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.Equals(testFile.GetAttrib(), FileGetAttrib(A_ScriptFullPath))
    }

    Flush_FlushesWriteBuffer() {
        tmp := FileOpen("tmp.txt", "w")
        tmp.Write("Hello World")
        tmp.Flush()

        Assert.Equals(FileRead("tmp.txt"), "Hello World")
        tmp.Close()
        FileDelete("tmp.txt")
    }

    GetSize_GetsSize() {
        tmp := FileOpen("tmp.txt", "w")
        tmp.Write("Hello World")
        tmp.Close()

        Assert.Equals(FileOpen("tmp.txt", "r").GetSize("Bytes"), 11)
        FileDelete("tmp.txt")
    }

    Path_GetsPath(){
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.Equals(testFile.Path, A_ScriptFullPath)
    }

    FileIndex_IsNonZero() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.NotEquals(testFile.FileIndex, 0)
    }

    VolumeSerialNumber_IsNonZero() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.NotEquals(testFile.VolumeSerialNumber, 0)
    }

    FileName_GetsName() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.Equals(testFile.FileName, A_ScriptName)
    }

    NameNoExt_GetsNameWithoutExtension() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.Equals(testFile.NameNoExt, SubStr(A_ScriptName, 1, -4))
    }

    FileExtension_GetsExtension() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.Equals(testFile.Extension, "ahk")
    }

    Directory_GetsDirectory() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        Assert.Equals(testFile.Directory, A_ScriptDir)
    }

    Drive_GetsDrive() {
        testFile := FileOpen(A_ScriptFullPath, "r")
        SplitPath(A_ScriptFullPath, , , , , &scriptDrive)
        Assert.Equals(testFile.Drive, scriptDrive)
    }
}

if(A_ScriptName == "FileExtensions.Test.ahk"){
    Yunit.Use(YunitStdOut).Test(FileExtensionTests)
}