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
	
	public static inline function nearest<T:{var x:Float; var y:Float;}>(x1:Float, y1:Float, objects:Array<T>, metric:Float->Float->Float->Float->Float):T {
		Sure.sure(objects != null && objects.length != 0);
		var smallest = metric(x1, y1, objects[0].x, objects[0].y);
		var closestIdx:Int = 0;
		for (i in 1...objects.length) {
			var distance = metric(x1, y1, objects[i].x, objects[i].y);
			if (distance < smallest) {
				smallest = distance;
				closestIdx = i;
			}
		}
		return objects[closestIdx];
	}
	
	public static inline function furthest<T:{var x:Float; var y:Float;}>(x1:Float, y1:Float, objects:Array<T>, metric:Float->Float->Float->Float->Float):T {
		Sure.sure(objects != null && objects.length != 0);
		var largest = metric(x1, y1, objects[0].x, objects[0].y);
		var furthestIdx:Int = 0;
		for (i in 1...objects.length) {
			var distance = metric(x1, y1, objects[i].x, objects[i].y);
			if (distance > largest) {
				largest = distance;
				furthestIdx = i;
			}
		}
		return objects[furthestIdx];
	}
}