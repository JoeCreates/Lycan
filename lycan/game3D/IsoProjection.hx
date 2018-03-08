package lycan.game3D;

import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import lycan.components.IsoEntity;
import lycan.game3D.components.Position3D;
import lycan.game3D.Point3D;

@:access(lycan.components.IsoComponent)
class IsoProjection {
	public static var iso:IsoProjection = new IsoProjection();
	
	public var width:Float;
	public var height:Float;
	public var depth:Float;
	public var lightVector:Point3D;
	public var lightColor:FlxColor;
	
	public function new(width:Float = 2, height:Float = 1, depth:Float = 1) {
		this.width = width;
		this.height = height;
		this.depth = depth;
		
		lightVector = Point3D.get(-1, 0, 4);
	}
	
	public function set(width:Float = 2, height:Float = 1, depth:Float = 1):IsoProjection {
		this.width = width;
		this.height = height;
		this.depth = depth;
		return this;
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
	
	public function sortByDepth(group:FlxTypedGroup<FlxObject>):Void {
		group.sort(byDepth, FlxSort.DESCENDING);
	}
	
	public static function byDepth(order:Int, oo1:FlxObject, oo2:FlxObject):Int {
		var o1:IsoEntity = cast oo1;
		var o2:IsoEntity = cast oo2;
		//o1.iso.
		var orderout = FlxSort.byValues(order, o1.pos3D.z, o2.pos3D.z);
		if (orderout != 0) return orderout;
		var o1xy:Float = o1.pos3D.x + o1.pos3D.y;
		var o2xy:Float = o2.pos3D.x + o2.pos3D.y;
		return FlxSort.byValues(order, o1xy, o2xy) * -1;
	}
}