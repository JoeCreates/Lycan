package lycan.constraint;

class Util {
	private static inline var eps:Float = 1.0e-8;
	
	public static inline function nearZero(value:Float):Bool {
		return value < 0.0 ? -value < eps : value < eps;
	}
}