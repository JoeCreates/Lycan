package lycan.util;

import flixel.math.FlxPoint;
import lycan.util.Point3D;

class IsoProjection {
	public var width:Float;
	public var height:Float;
	public var depth:Float;
	
	public function new(width:Float = 2, height:Float = 1, depth:Float = 1) {
		this.width = width;
		this.height = height;
		this.depth = depth;
	}
	
	public function toCart(?p2d:FlxPoint, p3d:Point3D):FlxPoint {
		if (p2d == null) p2d = FlxPoint.get();
		p2d.x = (p3d.x - p3d.y) * (width / 2);
		p2d.y = (p3d.x + p3d.y) * (height / 2) + p3d.z * depth;
		return p2d;
	}
	
	public function toIso(?p3d:Point3D, p2d:FlxPoint, z:Float = 0):Point3D {
		if (p3d == null) p3d = Point3D.get();
		p3d.x = (p2d.x / (width / 2) + p2d.y / (height / 2)) / 2;
		p3d.y = (p2d.y / (height / 2) - (p2d.x / (width / 2))) / 2;
		p3d.z = z;
		return p3d;
	}
}