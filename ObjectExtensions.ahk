#Requires AutoHotkey v2.0

#Include MapExtensions.ahk
#Include ArrayExtensions.ahk

class ObjectExtensions {
    static __New() {
        Object.Prototype.DefineProp("ToString", { Call: (self) => ObjectExtensions.ObjToString(self) })
    }

    static ObjToString(obj) {
        str := "{"

        allProps := Map()

        current := obj
        while(IsObject(current) && Type(current) != "Prototype") {
            for(key, value in ObjOwnProps(current)) {
                if(!allProps.Has(key))
                    allProps[key] := value
            }

            current := current.base
        }
        
        return Type(obj) . (allProps.Count > 0 ? String(allProps) : "")
    }
}

obj := {
    one: 1,
    two: 2,
    arrVal: Array()
}

MsgBox(String(Gui.Button))