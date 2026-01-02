#Requires AutoHotkey v2.0

/**
 * Provides extension methods and useful constants for Integer.
 * 
 *      while(myInt < Integer.Max) {
 *          ; Do stuff
 *      }
 */
class IntegerExtensions {
    static __New() {
        Integer.DefineProp("Max", { Get: (self) => 0x7FFFFFFFFFFFFFFF })
        Integer.DefineProp("Min", { Get: (self) => 0x8000000000000000 })

        Integer.DefineProp("Max32", { Get: (self) => 0x7FFFFFFF })
        Integer.DefineProp("Min32", { Get: (self) => 0x80000000 })
    }
}

/**
 * Provides extension methods and useful constants for Floating point values.
 * 
 *      if(thingFailed)
 *          return Float.NaN
 */
class FloatExtensions {
    static __New() {
        __ObjDefineProp := Object.Prototype.DefineProp

        ; Static methods
        Float.DefineProp("FromBits", { Get: (self, bits) => FloatExtensions.FromBits(bits) })
        Float.DefineProp("FromBits32", { Get: (self, bits) => FloatExtensions.FromBits32(bits) })
        Float.DefineProp("IsNaN", { Call: (self, val) => val != val })
        Float.DefineProp("IsInfinity", { Call: (self, val) => !val.IsNan && Abs(val) == Float.PositiveInfinity })
        Float.DefineProp("Truncate", { Call: (self, val, places) => FloatExtensions.Truncate(val, places) })

        ; Instance methods - this does work, even if it looks funny. E.g.:
        __ObjDefineProp(Float.Prototype, "IsNaN", { Get: (self) => self != self })
        __ObjDefineProp(Float.Prototype, "IsInfinity", { Get: (self) => !self.IsNan && Abs(self) == Float.PositiveInfinity })
        __ObjDefineProp(Float.Prototype, "Truncate", { Call: (self, places) => FloatExtensions.Truncate(self, places) })

        ; 64-bit float constants
        Float.DefineProp("Max", { Get: (self) => FloatExtensions.FromBits(0x7FEFFFFFFFFFFFFF) })
        Float.DefineProp("Min", { Get: (self) => FloatExtensions.FromBits(0x0000000000000001) })
        Float.DefineProp("MinNormal", { Get: (self) => FloatExtensions.FromBits(0x0010000000000000) })

        Float.DefineProp("PositiveInfinity", { Get: (self) => FloatExtensions.FromBits(0x7FF0000000000000) })
        Float.DefineProp("NegativeInfinity", { Get: (self) => FloatExtensions.FromBits(0xFFF0000000000000) })
        Float.DefineProp("NaN", { Get: (self) => FloatExtensions.FromBits(0x7FF8000000000000) })
        Float.DefineProp("Epsilon", {Get: (self) => FloatExtensions.FromBits(0x3CB0000000000000) })

        ; 32-bit float constants
        Float.DefineProp("Max32", { Get: (self) => FloatExtensions.FromBits32(0x7F7FFFFF) })
        Float.DefineProp("Min32", { Get: (self) => FloatExtensions.FromBits32(0x00000001) })
        Float.DefineProp("MinNormal32", { Get: (self) => FloatExtensions.FromBits32(0x00800000) })

        Float.DefineProp("PositiveInfinity32", { Get: (self) => FloatExtensions.FromBits32(0x7F800000) })
        Float.DefineProp("NegativeInfinity32", { Get: (self) => FloatExtensions.FromBits32(0xFF800000) })
        Float.DefineProp("NaN32", { Get: (self) => FloatExtensions.FromBits32(0x7FC00000) })

        ; Misc constants
        Float.DefineProp("Pi", { Get: (self) => 4 * ATan(1) })
        Float.DefineProp("E", { Get: (self) => 2.718281828459045235 })   ; Euler's constant - deriving requires a limit, so here we are
    }

    /**
     * Bitcast an Integer as a 64-bit (double-precision) floating point value.
     * 
     *      ; Identical to Float.Max
     *      maxFloat := Float.FromBits(0x7FEFFFFFFFFFFFFF)
     * 
     * @param {Integer} bits bits to read in, in Integer format. 
     * @returns {Float} the value of `bits` reinterpreted as a 64-bit Float (Double)
     */
    static FromBits(bits) {
        static buf := Buffer(8, 0)
        NumPut("uint64", bits, buf)
        return NumGet(buf, "double")
    }

    /**
     * Bitcast an Integer as a 32-bit (single-precision) floating point value.
     *  
     *      ; Identical to Float.PositiveInfinity32
     *      posInf32 := Float.FromBits32(0x7F800000)
     * 
     * @param {Integer} bits bits to read in, in Integer format. 
     * @returns {Float} the value of `bits` reinterpreted as a 32-bit Float (float)
     */
    static FromBits32(bits) {
        static buf := Buffer(4, 0)
        NumPut("uint32", bits, buf)
        return NumGet(buf, "float")
    }

    /**
     * Truncate a floating-point value to a certain number of decimal places.
     * 
     * @param {Float} val the value to truncate 
     * @param {Integer} places the number of decimal places to preserve
     * @returns {String} a numeric string with the results of the truncation. Note that
     *          converting this back to a float may introduce floating-point precision
     *          errors 
     */
    static Truncate(val, places) {
        fmt := "{1:." Integer(places) "f}"
        return Format(fmt, val)
    }
}

/**
 * Provides extension methods and constants common to all Number (Float / Integer) values.
 * These mostly map the built-in {@link https://www.autohotkey.com/docs/v2/lib/Math.htm math functions}.
 * 
 *      root := (100).Sqrt() ; 10.0
 */
class NumberExtensions {
    static __New() {
        NumDefineProp := Object.Prototype.DefineProp.Bind(Number.Prototype)

        NumDefineProp("Abs", { Call: (self) => Abs(self)})
        NumDefineProp("Round", { Call: (self, n := 0) => Round(self, n)})
        NumDefineProp("Ceil", { Call: (self) => Ceil(self)})
        NumDefineProp("Floor", { Call: (self) => Floor(self)})
        NumDefineProp("Exp", { Call: (self) => Exp(self)})
        NumDefineProp("Log", { Call: (self) => Log(self)})
        NumDefineProp("Ln", { Call: (self) => Ln(self)})
        NumDefineProp("Sqrt", { Call: (self) => Sqrt(self)})
        NumDefineProp("Mod", { Call: (self, other) => Mod(self, other)})

        NumDefineProp("Sin", { Call: (self) => Sin(self)})
        NumDefineProp("Cos", { Call: (self) => Cos(self)})
        NumDefineProp("Tan", { Call: (self) => Tan(self)})
        NumDefineProp("ASin", { Call: (self) => ASin(self)})
        NumDefineProp("ACos", { Call: (self) => ACos(self)})
        NumDefineProp("ATan", { Call: (self) => ATan(self)})

        NumDefineProp("Clamp", { Call: (self, minVal, maxVal) => Max(minVal, Min(self, maxVal))})

        Number.DefineProp("Clamp", { Call: (self, num, minVal, maxVal) => Max(minVal, Min(num, maxVal))})
    }
}

;@Ahk2Exe-IgnoreBegin
if(A_ScriptName == "NumberExtensions.ahk"){
    MsgBox(Integer.Min)
    MsgBox((100).Sqrt())
}
;@Ahk2Exe-IgnoreEnd
