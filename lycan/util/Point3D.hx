package lycan.util;

import flash.geom.Point;
import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxStringUtil;
import openfl.geom.Matrix;
import openfl.geom.Vector3D;

class Point3D extends Vector3D implements IFlxPooled {
	
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
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0) {
		super(x, y, z, w);
	}
	
	public function set(x:Float = 0, y:Float = 0, z:Float = 0):Point3D {
		this.setTo(x, y, z);
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