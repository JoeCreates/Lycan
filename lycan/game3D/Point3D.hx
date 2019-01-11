package lycan.game3D;

import flash.geom.Point;
import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxStringUtil;
import openfl.geom.Matrix;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;

class Point3D implements IFlxPooled {
	
	public static var pool(get, never):IFlxPool<Point3D>;
	private static var _pool = new FlxPool<Point3D>(Point3D);
	
	public static inline function get(x:Float = 0, y:Float = 0, z:Float = 0):Point3D {
		var point = _pool.get().set(x, y, z);
		point._inPool = false;
		return point;
	}
	
	public static inline function weak(x:Float = 0, y:Float = 0, z:Float = 0):Point3D {
		var point = get(x, y, z);
		point._weak = true;
		return point;
	}
	
	private static function get_pool():IFlxPool<Point3D> {
		return _pool;
	}
	
	private var _weak:Bool = false;
	private var _inPool:Bool = false;
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public var length(get, null):Float;
	public var lengthSquared (get, null):Float;
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public function crossProduct(a:Point3D):Point3D {
		var nx = y * a.z - z * a.y;
		var ny = z * a.x - x * a.z;
		var nz = x * a.y - y * a.x;
		return set(nx, ny, nz);
	}
	
	public function dotProduct(a:Point3D):Float {
		return x * a.x + y * a.y + z * a.z;
	}
	
	public function set(x:Float = 0, y:Float = 0, z:Float = 0):Point3D {
		this.x = x;
		this.y = y;
		this.z = z;
		return this;
	}
	
	public inline function add(x:Float = 0, y:Float = 0, z:Float = 0):Point3D {
		this.x += x;
		this.y += y;
		this.z += z;
		return this;
	}
	
	public inline function subtract(x:Float = 0, y:Float = 0, z:Float = 0):Point3D {
		return add(-x, -y, -z);
	}
	
	public function addPoint(a:Point3D):Point3D {
		return add(a.x, a.y, a.z);
	}
	
	public function subtractPoint(a:Point3D):Point3D {
		return subtract(a.x, a.y, a.z);
	}
	
	public function ciel():Point3D {
		x = Math.fceil(x);
		y = Math.fceil(y);
		z = Math.fceil(z);
		return this;
	}
	
	public function floor(floorX:Bool = true, floorY:Bool = true, floorZ:Bool = true):Point3D {
		if (floorX) x = Math.ffloor(x);
		if (floorY) y = Math.ffloor(y);
		if (floorZ) z = Math.ffloor(z);
		return this;
	}
	
	public function copyFrom(p:Point3D):Point3D {
		return set(p.x, p.y, p.z);
	}
	
	public function copyFromFlash(v:Vector3D):Point3D {
		return set(v.x, v.y, v.z);
	}
	
	public function copyTo(p:Point3D):Point3D {
		return p.copyFrom(this);
	}
	
	public function scale(scale:Float):Point3D {
		return set(x * scale, y * scale, z * scale);
	}
	
	public function entrywiseProduct(p:Point3D):Point3D {
		return set(x * p.x, y * p.y, z * p.z);
	}
	
	public function distanceTo(p:Point3D):Float {
		var dx:Float = p.x - x;
		var dy:Float = p.y - y;
		var dz:Float = p.z - z;
		
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}
	
	public function distanceToXYZ(x:Float, y:Float, z:Float):Float {
		var dx:Float = x - this.x;
		var dy:Float = y - this.y;
		var dz:Float = z - this.z;
		
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}
	
	public function angleBetween(p:Point3D):Float {
		var l = length;
		var pl = p.length;
		var dot = dotProduct(p);
		
		if (l != 0) dot /= l;
		if (pl != 0) dot /= pl;
		
		return Math.acos(dot);
	}
	
	public function equals(p:Point3D):Bool {
		return p.x == x && p.y == y && p.z == z;
	}
	
	private function get_length():Float {
		return Math.sqrt(x * x + y * y + z * z);
	}
	
	private function get_lengthSquared():Float {
		return x * x + y * y + z * z;
	}
	
	public function normalize():Point3D {
		var l = length;
		
		if (l != 0) {
			x /= l;
			y /= l;
			z /= l;
		}
		
		return this;
	}
	
	public function transform(m:Matrix3D):Point3D {
		var rawData = m.rawData;
		return
			set((x * rawData[0] + y * rawData[4] + z * rawData[8] + rawData[12]),
			(x * rawData[1] + y * rawData[5] + z * rawData[9] + rawData[13]),
			(x * rawData[2] + y * rawData[6] + z * rawData[10] + rawData[14]));
	}
	
	public function put():Void {
		if (!_inPool) {
			_inPool = true;
			_weak = false;
			_pool.putUnsafe(this);
		}
	}
	
	public inline function putWeak():Void {
		if (_weak) put();
	}
	
	public inline function toString():String {
		return FlxStringUtil.getDebugString([ 
			LabelValuePair.weak("x", x),
			LabelValuePair.weak("y", y),
			LabelValuePair.weak("z", z)
			]);
	}
	
	public function destroy() {}
	
}