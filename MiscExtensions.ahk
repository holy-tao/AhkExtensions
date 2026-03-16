
/**
 * Provides extension methods to {@link https://www.autohotkey.com/docs/v2/Concepts.htm#variable-references VarRefs}
 */
class VarRefExtensions {
    static __New() {
        VarRef.Prototype.DefineProp := Object.Prototype.DefineProp

        VarRef.DefineProp("Empty", { Call: (*) => &empty := "" }) ; Returns a new reference to an empty string
        VarRef.Prototype.DefineProp("Deref", { Call: (self) => %self%})
        VarRef.Prototype.DefineProp("ToString", { Call: (self) => Format("&{1}", String(%self%)) })
    }
}