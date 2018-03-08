package lycan.game3D;

import lycan.game3D.Point3D;
import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPooled;

@:tink
class Box implements IFlxPooled {
	
	// -- Pooling --
	public static var pool(get, never):IFlxPool<Box>;
	private static var _pool = new FlxPool<Box>(Box);
	public static inline function get(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0, h:Float = 0, d:Float = 0):Box {
		var b = _pool.get().set(x, y, z, w, h, d);
		b._inPool = false;
		return b;
	}
	public static inline function weak(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0, h:Float = 0, d:Float = 0):Box {
		var b = get();
		b._weak = true;
		return b;
	}
	private static function get_pool():IFlxPool<Box> return _pool;
	
	private var _weak:Bool = false;
	private var _inPool:Bool = false;
	public inline function put():Void {
		if (!_inPool) {
			_inPool = true;
			_weak = false;
			_pool.putUnsafe(this);
		}
	}
	public inline function putWeak():Void {
		if (_weak) put();
	}
	//-- End Pooling --
	
	/** Relative position of hitbox */
	public var pos(default, null):Point3D;
	public var width(default, set):Float;
	public var height(default, set):Float;
	public var depth(default, set):Float;
	
	@:calc var minX:Float = pos.x;
 	@:calc var minY:Float = pos.y;
	@:calc var minZ:Float = pos.z;
	@:calc var maxX:Float = pos.x + width;
	@:calc var maxY:Float = pos.y + height;
	@:calc var maxZ:Float = pos.z + depth;
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0, h:Float = 0, d:Float = 0) {
		pos = Point3D.get(x, y, z);
		this.width = w;
		this.height = h;
		this.depth = d;
	}
	
	public function set(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0, h:Float = 0, d:Float = 0):Box {
		pos.set(x, y, z);
		setSize(w, h, d);
		return this;
	}
	
	public static function overlaps(h1:Box, h2:Box, ?pos1:Point3D, ?pos2:Point3D):Bool {
		// Calculate absolute positions
		if (pos1 != null) h1.pos.addPoint(pos1);
		if (pos2 != null) h2.pos.addPoint(pos2);
		
		var out:Bool = (h1.maxX > h2.minX && h2.maxX > h1.minX) &&
			   (h1.maxY > h2.minY && h2.maxY > h1.minY) &&
			   (h1.maxZ > h2.minZ && h2.maxZ > h1.minZ);
		
		if (pos1 != null) h1.pos.subtractPoint(pos1);
		if (pos2 != null) h2.pos.subtractPoint(pos2);
		
		return out;
	}
	
	public function setSize(width:Float = 0, height:Float = 0, depth:Float = 0):Box {
		this.width = width;
		this.height = height;
		this.depth = depth;
		return this;
	}
	
	public function destroy():Void {
		pos = null;
	}
	
	private function set_width(value:Float):Float {
		return this.width = value;
	}
	
	private function set_height(value:Float):Float {
		return this.height = value;
	}
	
	private function set_depth(value:Float):Float {
		return this.depth = value;
	}
}