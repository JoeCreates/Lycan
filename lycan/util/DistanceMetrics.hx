package lycan.util;

import flixel.math.FlxPoint;

class DistanceMetrics {
	public static inline function manhattan(p1:FlxPoint, p2:FlxPoint):Float {
		return Math.abs(p1.x - p2.x) + Math.abs(p1.y - p2.y);
	}
	
	public static inline function chebyshev(p1:FlxPoint, p2:FlxPoint):Float {
		return Math.max(Math.abs(p1.x - p2.x), Math.abs(p1.y - p2.y));
	}
}