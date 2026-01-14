#Include ./YUnit/Assert.ahk
#Include ./YUnit/YUnit.ahk
#Include ./YUnit/ResultCounter.ahk
#Include ./YUnit/JUnit.ahk
#Include ./YUnit/Stdout.ahk

#Include FileExtensions.Test.ahk
#Include ArrayExtensions.Test.ahk
#include MapExtensions.Test.ahk
#Include BufferExtensions.Test.ahk
#Include NumberExtensions.test.ahk

YUnit.Use(YunitResultCounter, YUnitJUnit, YUnitStdOut).Test(
    FileExtensionTests,
    ArrayExtensionTests,
    BufferExtensionTests,
    MapExtensions,
    IntegerExtensionTests,
    FloatExtensionTests,
    NumberExtensionTests
)

Exit(-YunitResultCounter.failures)