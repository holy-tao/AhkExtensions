# AhkExtensions
[![Unit Tests](https://github.com/holy-tao/AhkExtensions/actions/workflows/unit-tests.yml/badge.svg)](https://github.com/holy-tao/AhkExtensions/actions/workflows/unit-tests.yml)

Extension library for built-in AutoHotkey types. I use these personally for convenience, this repository exists largely to organize them.

### Usage
Clone the repo into a [library folder](https://www.autohotkey.com/docs/v2/Scripts.htm#lib) - note that for import readability I name the actual directory "Extensions":

```cmd
cd ~\Documents\AutoHotkey\Lib\
git clone git@github.com:holy-tao/AhkExtensions.git Extensions
```

Now you can simply [`#Include`](https://www.autohotkey.com/docs/v2/lib/_Include.htm) the extensions you require in your scripts. The extensions add properties directly to the types they extend; you don't need to do any extra work. The extensions should behave as though they were native builtins.

```autohotkey
#Include <Extensions/ArrayExtensions>

arr := [1, 2, 3, 4, 5]
first := arr.First() ; 1
```

Under the hood, extensions all work by [defining properties](https://www.autohotkey.com/docs/v2/lib/Object.htm#DefineProp) on an object's [prototype](https://www.autohotkey.com/docs/v2/lib/Class.htm#Prototype). In some cases these may simply invoke builtins (e.g. the [`NumberExtensions`](./NumberExtensions.ahk) add methods like `Sqrt` which simply call the [builtin](https://www.autohotkey.com/docs/v2/lib/Math.htm#Sqrt)), but most will invoke static methods on a class called `<Type>Extensions`. These methods can of course be called directly, should you want to.

Documentation is included in the scripts themselves. This is not surfaced in editor extensions unfortunately.

### Dependencies
[`FileExtensions.ahk`](FileExtensions.ahk) requires some types from my [Win32 bindings](https://github.com/holy-tao/AhkWin32Projection) to be available in a library folder. Note that because this is really my personal "AHK stack", I'm not going to avoid using other libraries, particularly my own.