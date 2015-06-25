package ai;

class Strength {
	public static inline var required = create(1000.0, 1000.0, 1000.0);
	public static inline var strong = create(1.0, 0.0, 0.0);
	public static inline var medium = create(0.0, 1.0, 0.0);
	public static inline var weak = create(0.0, 0.0, 1.0);
	
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