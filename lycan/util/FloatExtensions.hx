package lycan.util;

// Extension methods for floats
class FloatExtensions {
	public static inline function clamp(v:Float, min:Float, max:Float):Float {
		return (v < min ? min : (v > max ? max : v));
	}
	
	public static inline function max<T:Float>(a:T, b:T):T {
		return (a > b ? a : b);
	}
	
	public static inline function min<T:Float>(a:T, b:T):T {
		return (a < b ? a : b);
	}
}