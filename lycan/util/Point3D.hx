package lycan.util;

import flash.geom.Point;
import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxStringUtil;
import openfl.geom.Matrix;
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
	
	public var length(get, null):Float;
	public var lengthSquared (get, null):Float;
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public function crossProduct(a:Point3D):Void {
		x = y * a.z - z * a.y;
		y = z * a.x - x * a.z;
		z = x * a.y - y * a.x;
		return this;
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
		this.x += z;
		return this;
	}
	
	public inline function subtract(x:Float = 0, y:Float = 0, z:Float = 0):Point3D {
		return add(-x, -y, -z);
	}
	
	public function addPoint(a:Point3D):Point3D {
		return add(a.x, a.y, a.z);
	}
	
	public function subtractPoint():Point3D {
		return subtract(a.x, a.y, a.z);
	}
	
	public function ciel():Point3D {
		x = Math.fceil(x);
		y = Math.fceil(y);
		z = Math.fceil(z);
		return this;
	}
	
	public function floor():Point3D {
		x = Math.ffloor(x);
		y = Math.ffloor(y);
		z = Math.ffloor(z);
	}
	
	public function copyFrom(p:Point3D):Point3D {
		return set(p.x, p.y, p.z);
	}
	
	public function copyFromFlash(v:Vector3D):Point3D {
		return set(v.x, v.y, v.z);
	}
	
	public function copyTo(p:Point3D):Point3D {
		p.copyFrom(this);
	}
	
	public function scale(scale):Point3D {
		return this.set(x * scale, y * scale, z * scale);
	}
	
	public function distanceTo(p:Point3D):Float {
		var dx:Float = p.x - x;
		var dy:Float = p.y - y;
		var dz:Float = p.z - z;
		
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}
	
	public function angleBetween(p:Point3D):Float {
		var la = length;
		var lb = b.length;
		var dot = a.dotProduct(b);
		
		if (la != 0) dot /= length;
		if (lb != 0) dot /= b.length;
		
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
	
	public function destroy() {}
	
}