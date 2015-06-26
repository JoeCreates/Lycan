package lycan.constraint;

class Strength {
	public static var required(default,never) = macro_create(1000.0, 1000.0, 1000.0);
	public static var strong(default,never) = macro_create(1.0, 0.0, 0.0);
	public static var medium(default,never) = macro_create(0.0, 1.0, 0.0);
	public static var weak(default,never) = macro_create(0.0, 0.0, 1.0);
	
	macro private static inline function macro_create(a:Float, b:Float, c:Float, w:Float = 1.0) {
		return macro $v { create(a, b, c, w) };
	}
	
	public static inline function create(a:Float, b:Float, c:Float, w:Float = 1.0):Float {
		var result = 0.0;
		result += Math.max(0.0, Math.min(1000.0, a * w)) * 1000000.0;
		result += Math.max(0.0, Math.min(1000.0, b * w)) * 1000.0;
		result += Math.max(0.0, Math.min(1000.0, c * w));
		return result;
	}
	
	public static inline function clip(value:Float):Float {
		return Math.max(0.0, Math.min(required, value));
	}
}