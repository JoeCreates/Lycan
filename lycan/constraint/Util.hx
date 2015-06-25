package lycan.constraint;

class Util {
	public static inline function nearZero(value:Float):Bool {
		var eps:Float = 0.00000001; // TODO figure out a sensible value for this across platforms
		return value < 0.0 ? -value < eps : value < eps;
	}
}