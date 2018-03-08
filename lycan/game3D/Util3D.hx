package lycan.game3D;

import flixel.FlxG;
import flixel.math.FlxRandom;
import haxe.ds.Vector;
import lycan.game3D.Point3D;
import openfl.geom.Vector3D;

class Util3D {
	
	public static function getNormal(v1:Point3D, v2:Point3D, v3:Point3D, ?out:Point3D):Point3D {
		if (out == null) out = Point3D.get();
		
		out.copyFrom(v1).subtractPoint(v2);
		var b:Point3D = Point3D.get().copyFrom(v1).subtractPoint(v3);
		
		out = out.crossProduct(b);
		
		b.put();
		return out;
		
	}
	
	public static function getArea(v1:Point3D, v2:Point3D, v3:Point3D):Float {
		var a:Point3D = Point3D.get().copyFrom(v2).subtractPoint(v1);
		var b:Point3D = Point3D.get().copyFrom(v3).subtractPoint(v1);
		var out:Float = a.crossProduct(b).length / 2;
		a.put();
		b.put();
		return out;
	}
	
	public static function getMid(points:Array<Point3D>):Point3D {
		var mid:Point3D = Point3D.get();
		for (p in points) {
			mid.addPoint(p);
		}
		return mid.scale(1 / points.length);
	}
	
	public static function getRandomPointWithin(points:Array<Point3D>, ?weights:Array<Float>, ?random:FlxRandom, ?out:Point3D):Point3D {
		var generateWeights:Bool = false;
		
		if (random == null) random = FlxG.random;
		if (out == null) {
			out = Point3D.get();
		} else {
			out.set();
		}
		if (weights == null) {
			weights = [];
			generateWeights = true;
		} else {
			if (weights.length != points.length) throw("Weights must be same size and points");
		}
			
		// Give each source point a random weight
		var totalWeight:Float = 0;
		for (i in 0...points.length) {
			if (generateWeights) weights.push(random.float());
			totalWeight += weights[i];
		}
		
		// Normalise weights so they sum to 1
		// Then apply to output point
		var unitWeight:Float = 1 / totalWeight;
		for (i in 0...weights.length) {
			var nw:Float = weights[i] * unitWeight;
			var p:Point3D = points[i];
			out.add(nw * p.x, nw * p.y, nw * p.z);
		}
		
		return out;
	}
	
	public static function getQuadArea(v1:Point3D, v2:Point3D, v3:Point3D, v4:Point3D):Float {
		var mid:Point3D = getMid([v1, v2, v3, v4]);
		return getArea(v1, v2, mid) + getArea(v2, v3, mid) + getArea(v3, v4, mid) + getArea(v1, v4, mid);
	}
	
	
}