package lycan.game3D.components;

import flixel.math.FlxVelocity;
import lycan.game3D.DirectionMask3D;
import lycan.game3D.Box;
import lycan.game3D.components.Position3D;
import lycan.game3D.Point3D;
import lycan.components.Entity;
import lycan.components.Component;

interface Physics3D extends Entity {
	public var phys:Physics3DComponent;
	public var pos3D:Position3DComponent;
	@:relaxed public var exists(get, set):Bool;
}

@:tink
class Physics3DComponent extends Component<Physics3D> {
	
	/** Convenient accessor of pos3D x */
	@:prop(entity.pos3D.x, entity.pos3D.x = param) var x:Float;
	/** Convenient accessor of pos3D y */
	@:prop(entity.pos3D.y, entity.pos3D.y = param) var y:Float;
	/** Convenient accessor of pos3D z */
	@:prop(entity.pos3D.z, entity.pos3D.z = param) var z:Float;
	@:prop(entity.pos3D.point, entity.pos3D.point = param) var pos:Point3D;
	//@:property(entity.entity_exists, entity.entity_exists = param) var exists:Bool;
	
	public var hitBox:Box;
	public var active:Bool = true;
	public var immovable:Bool = false;
	public var solid(get, set):Bool;
	public var velocity(default, null):Point3D;
	public var acceleration(default, null):Point3D;
	public var drag(default, null):Point3D;
	public var maxVelocity(default, null):Point3D;
	public var last(default, null):Point3D;
	public var mass:Float = 1;
	public var elasticity:Float = 0;
	//public var angle:Point3D should be part of position?
	//public var angularVelocity:Point3D;//TODO
	//public var angularAcceleration:Point3D;//TODO
	//public var angularDrag:Point3D;//TODO
	//public var maxAngular:Point3D;
	public var touching:DirectionMask3D;
	public var wasTouching:DirectionMask3D;
	public var allowCollisions:DirectionMask3D;
	public var followMovementSurfaces:DirectionMask3D;
	//TODO debug drawing
	
	private var _point:Point3D;
	
	public function new(entity:Physics3D) {
		super(entity);
		
		hitBox = new Box();
		
		touching = DirectionMask3D.NONE;
		wasTouching = DirectionMask3D.NONE;
		allowCollisions = DirectionMask3D.ANY;
		followMovementSurfaces = DirectionMask3D.BOTTOM;
		
		velocity = Point3D.get();
		acceleration = Point3D.get();
		drag = Point3D.get();
		var inf:Float = Math.POSITIVE_INFINITY;
		maxVelocity = Point3D.get(inf, inf, inf);
		
		last = Point3D.get(x, y, z);
		
		_point = Point3D.get();
	}
	
	@:prepend("update")
	public function update(dt:Float):Void {
		last.copyFrom(pos);
		
		//TODO midpoint reimman summation like flixel updateMotion?
		if (active) {
			velocity.set(
				FlxVelocity.computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x, dt),
				FlxVelocity.computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y, dt),
				FlxVelocity.computeVelocity(velocity.z, acceleration.z, drag.z, maxVelocity.z, dt)
			);
			pos.addPoint(_point.copyFrom(velocity).scale(dt));
		}
		
		wasTouching = touching;
		touching = DirectionMask3D.NONE;
	}
	
	//TODO
	public function destroy():Void {
		
	}
	
	public inline function justTouched(direction:DirectionMask3D):Bool {
		return !wasTouching.getFlag(direction) && touching.getFlag(direction);
	}
	
	private inline function get_solid():Bool {
		return (allowCollisions & DirectionMask3D.ANY) != DirectionMask3D.NONE;
	}
	
	private function set_solid(solid:Bool):Bool {
		allowCollisions = solid ? DirectionMask3D.ANY : DirectionMask3D.NONE;
		return solid;
	}
}
