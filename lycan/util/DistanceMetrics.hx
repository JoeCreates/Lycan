package lycan.util;

import flixel.math.FlxPoint;

class DistanceMetrics {
	public static inline function manhattan(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.abs(x1 - x2) + Math.abs(y1 - y2);
	}
	
	public static inline function chebyshev(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.max(Math.abs(x1 - x2), Math.abs(y1 - y2));
	}
	
	public static inline function euclidean(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.sqrt(euclideanSquared(x1, y1, x2, y2));
	}
	
	public static inline function euclideanSquared(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		return Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2);
	}
}