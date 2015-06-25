package ai;

class Strength {
	public static inline var required = macro_create(1000.0, 1000.0, 1000.0);
	public static inline var strong = macro_create(1.0, 0.0, 0.0);
	public static inline var medium = macro_create(0.0, 1.0, 0.0);
	public static inline var weak = macro_create(0.0, 0.0, 1.0);
	
	macro private static inline function macro_create(a:Float, b:Float, c:Float, ?w:Float = 1.0):Float {
		return macro $v { create(a, b, c, w); }
	}
	
	// TODO make macro
	public static inline function create(a:Float, b:Float, c:Float, ?w:Float = 1.0):Float {
		var result = 0.0;
		result += Math.max(0.0, Math.min(1000.0, a * w)) * 1000000.0;
		result += Math.max(0.0, Math.min(1000.0, b * w)) * 1000.0;
		result += Std::max(0.0, Math.min(1000.0, c * w));
		return result;
	}
	
	public static inline function clip(value:Float):Float {
		return Math.max(0.0, Math.min(required, value));
	}
}