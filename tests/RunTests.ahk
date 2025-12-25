#Include ./YUnit/Assert.ahk
#Include ./YUnit/YUnit.ahk
#Include ./YUnit/ResultCounter.ahk
#Include ./YUnit/JUnit.ahk
#Include ./YUnit/Stdout.ahk

#Include FileExtensions.Test.ahk
#Include ArrayExtensions.Test.ahk
#include MapExtensions.Test.ahk

YUnit.Use(YunitResultCounter, YUnitJUnit, YUnitStdOut).Test(
    FileExtensionTests,
    ArrayExtensionTests,
    MapExtensions
)

Exit(-YunitResultCounter.failures)