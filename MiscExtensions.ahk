
/**
 * Provides extension methods to {@link https://www.autohotkey.com/docs/v2/Concepts.htm#variable-references VarRefs}
 */
class VarRefExtensions {
    static __New() {
        __ObjDefineProp := Object.Prototype.DefineProp

        VarRef.DefineProp("Empty", { Call: (*) => &empty := "" }) ; Returns a new reference to an empty string
        __ObjDefineProp(VarRef.Prototype, "Deref", { Call: (self) => %self%})
        __ObjDefineProp(VarRef.Prototype, "ToString", { Call: (self) => Format("&{1}", String(%self%)) })
    }
}