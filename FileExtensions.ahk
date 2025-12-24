#Requires AutoHotkey v2.0

#Include <AhkWin32Projection\Windows\Win32\Storage\FileSystem\Apis>
#Include <AhkWin32Projection\Windows\Win32\System\Time\Apis>
#Include <AhkWin32Projection\Windows\Win32\Foundation\SYSTEMTIME>
#Include <AhkWin32Projection\Windows\Win32\Storage\FileSystem\BY_HANDLE_FILE_INFORMATION>
#Include <AhkWin32Projection\Windows\Win32\Storage\FileSystem\FILE_FLAGS_AND_ATTRIBUTES>
#Include <AhkWin32Projection\Windows\Win32\Storage\FileSystem\GETFINALPATHNAMEBYHANDLE_FLAGS>

/**
 * Provides extension methods for {@link https://www.autohotkey.com/docs/v2/lib/File.htm Files}
 * 
 * Requires some types from https://github.com/holy-tao/AhkWin32Projection
 */
class FileExtensions {
    static __New() {
        ; Accessing the handle forces a flush, but it's strange to read
        File.Prototype.DefineProp("Flush", { Call: (self) => self.Handle })

        ; "Easy" one-offs
        File.Prototype.DefineProp("GetSize", { Call: (self, units?) => FileExtensions.GetSize(self, units?) })
        File.Prototype.DefineProp("Links", { Get: (self) => FileExtensions._GetInfo(self).nNumberOfLinks })
        File.Prototype.DefineProp("VolumeSerialNumber", { Get: (self) => FileExtensions._GetInfo(self).dwVolumeSerialNumber })
        File.Prototype.DefineProp("FileIndex", { Get: (self) => FileExtensions.GetFileIndex(self) })

        ; ====== Path Information (Likely will not work for e.g. pipes) ======
        File.Prototype.DefineProp("Path", { Get: (self) => FileExtensions.GetPath(self) })
        File.Prototype.DefineProp("FileName", { Get: (self) => 
            (SplitPath(FileExtensions.GetPath(self), &name), name) })
        File.Prototype.DefineProp("Directory", { Get: (self) => 
            (SplitPath(FileExtensions.GetPath(self), , &dir), dir) })
        File.Prototype.DefineProp("Extension", { Get: (self) => 
            (SplitPath(FileExtensions.GetPath(self), , , &ext), ext) })
        File.Prototype.DefineProp("Drive", { Get: (self) => 
            (SplitPath(FileExtensions.GetPath(self), , , , , &drive), drive) })
        File.Prototype.DefineProp("NameNoExt", { Get: (self) => 
            (SplitPath(FileExtensions.GetPath(self), , , , &nameNoExt), nameNoExt) })

        File.Prototype.DefineProp("GetCreationTime", { Call: (self, &ms := 0) => 
            FileExtensions.GetTime(self, "Creation", &ms)})

        ; ====== Attributes ======
        ; Gets the raw attribute enumeration
        File.Prototype.DefineProp("Attributes", { Get: (self) => FileExtensions._GetInfo(self).dwFileAttributes })
        ; Gets attributes in the format of `FileGetAttrib` - https://www.autohotkey.com/docs/v2/lib/FileGetAttrib.htm
        File.Prototype.DefineProp("GetAttrib", { Call: (self) => FileExtensions.GetAttrib(self) })

        ; One-offs - for performance reasons if you want to check more than one of these, you may prefer to get
        ; the all attributes and compare flags yourself to safe on DllCalls.
        File.Prototype.DefineProp("IsReadOnly", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_READONLY) })
        File.Prototype.DefineProp("IsHidden", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_HIDDEN) })
        File.Prototype.DefineProp("IsSystem", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_SYSTEM) })
        File.Prototype.DefineProp("IsDirectory", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_DIRECTORY) })
        File.Prototype.DefineProp("IsArchive", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_ARCHIVE) })
        File.Prototype.DefineProp("IsNormal", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_NORMAL) })
        File.Prototype.DefineProp("IsTemporary", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_TEMPORARY) })
        File.Prototype.DefineProp("IsReparsePoint", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_REPARSE_POINT) })
        File.Prototype.DefineProp("IsCompressed", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_COMPRESSED) })
        File.Prototype.DefineProp("IsOffline", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_OFFLINE) })
        File.Prototype.DefineProp("IsEncrypted", { Get: (self) => 
            FILE_FLAGS_AND_ATTRIBUTES.HasFlag(self.Attributes, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_ENCRYPTED) })
    }

    /**
     * Gets the full resolved path of a file, e.g. `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`. Symbolic
     * links are followed; if you opened a symlink to a file, the file object's `Path` is the path to the underlying 
     * file.
     * 
     * @param {File} forFile the file to get the path of
     * @returns {String} the full normalized path to the file, including volume. 
     */
    static GetPath(forFile) {
        pathBuf := Buffer(2 * (Foundation.MAX_PATH + 1), 0)
        length := FileSystem.GetFinalPathNameByHandleW(
            forFile.Handle,
            pathBuf,
            Foundation.MAX_PATH + 1,
            GETFINALPATHNAMEBYHANDLE_FLAGS.FILE_NAME_NORMALIZED | GETFINALPATHNAMEBYHANDLE_FLAGS.VOLUME_NAME_DOS
        )

        return StrGet(pathBuf.ptr + 8, length - 4, "UTF-16") ; Exclude the "\\?\"
    }

    /**
     * Retrieves the size of the file, optionally converting it. You must have opened the file with read permissions.
     * 
     *      kb := FileOpen(A_ScriptFullPath, "r").GetSize("K")
     * 
     * @param {File} forFile An open file to get the size of
     * @param {String} units If blank or omitted, it defaults to B. Otherwise, specify one of the 
     *          following letters to cause the result to be returned in specific units:
     *          <ul>
     *          <li> `B` = Bytes </li>
     *          <li> `K` = Kilobytes </li>
     *          <li> `M` = Megabytes </li>
     *          <li> `G` = Gigabytes </li>
     *          </ul>
     * @returns {Number} the size of the file.
     */
    static GetSize(forFile, units := "B") {
        unitChar := StrUpper(SubStr(units, 1, 1))  ; Just take the first letter - so e.g. "Megabytes" is valid
        bytes := 0

        ; Not worth using the projection for a LARGE_INTEGER struct
        if(!DllCall("GetFileSizeEx", "ptr", forFile.Handle, "int64*", &bytes, "int")) {
            throw OSError(A_LastError, -1)
        }

        switch(unitChar) {
            case "B":
                return bytes
            case "K":
                return bytes / 1000
            case "M":
                return bytes / 1e+6
            case "G":
                return bytes / 1e+9
            default:
                throw ValueError("Invalid units", -1, units)
        }
    }

    /**
     * Gets file attributes in the format of [`FileGetAttrib`](https://www.autohotkey.com/docs/v2/lib/FileGetAttrib.htm)
     * 
     * @param {File} forFile the file to get information about
     * @returns {String} A subset of `RASHNDOCTL` - see `FileGetAttrib` docs for details
     */
    static GetAttrib(forFile) {
        attrs := forFile.Attributes
        attribStr := ""

        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_READONLY)){
            attribStr .= "R"
        }
        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_ARCHIVE)){
            attribStr .= "A"
        }
        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_SYSTEM)){
            attribStr .= "S"
        }
        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_HIDDEN)){
            attribStr .= "H"
        }
        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_NORMAL)){
            attribStr .= "N"
        }
        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_DIRECTORY)){
            attribStr .= "D"
        }
        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_OFFLINE)){
            attribStr .= "O"
        }
        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_COMPRESSED)){
            attribStr .= "C"
        }
        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_TEMPORARY)){
            attribStr .= "T"
        }
        if(FILE_FLAGS_AND_ATTRIBUTES.HasFlag(attrs, FILE_FLAGS_AND_ATTRIBUTES.FILE_ATTRIBUTE_REPARSE_POINT)){
            attribStr .= "L"
        }

        return attribStr
    }

    /**
     * Gets the time of a file as a local AHK `YYYYMMDD24HHMMSS` string
     * 
     * @param {File} forFile the file to get information about
     * @param {String} timeKind the type of time to retrieve (C = Creation, A = Last Access, W = Last Write)
     * @param {VarRef<Integer>} milliseconds an optional output variable that receives the number
     *          of milliseconds from the timestamp
     * @returns {String} the time in the format `YYYYMMDD24HHMMSS`
     */
    static GetTime(forFile, timeKind, &milliseconds := 0) {
        info := FileExtensions._GetInfo(forFile)
        utcTime := ""

        switch(StrUpper(SubStr(timeKind, 1, 1))) {
            case "C":
                utcTime := info.ftCreationTime
            case "A":
                utcTime := info.ftLastAccessTime
            case "W":
                utcTime := info.ftLastWriteTime
            default:
                throw ValueError("Invalid time kind", -1, timeKind)
        }

        localTime := FILETIME(), sysTime := SYSTEMTIME()
        FileSystem.FileTimeToLocalFileTime(utcTime, localTime)
        Time.FileTimeToSystemTime(localTime, sysTime)

        milliseconds := sysTime.wMilliseconds
        return Format("{:04d}{:02d}{:02d}{:02d}{:02d}{:02d}", 
            sysTime.wYear, sysTime.wMonth, sysTime.wDay, sysTime.wHour, sysTime.wMinute, sysTime.wSecond)
    }

    /**
     * Retrieves the file index of the file
     * 
     * @param {File} forFile the file to get information about
     * @returns {Integer} the file index
     */
    static GetFileIndex(forFile) {
        fileInfo := FileExtensions._GetInfo(forFile)
        return fileInfo.nFileIndexHigh << 32 | fileInfo.nFileIndexLow
    }

    /**
     * Retrieves information about the file - see {@link FileSystem.GetFileInformationByHandle}
     * 
     * @param {File} forFile the file to get information about 
     * @returns {BY_HANDLE_FILE_INFORMATION} struct with file information
     */
    static _GetInfo(forFile) {
        fileInfo := BY_HANDLE_FILE_INFORMATION()
        FileSystem.GetFileInformationByHandle(forFile.Handle, fileInfo)
        FileAppend("BY_HANDLE_FILE_INFORMATION ptr=" fileInfo.ptr "`n" fileInfo.HexDump(), "*")
        return fileInfo
    }
}
