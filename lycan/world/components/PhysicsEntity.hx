package lycan.world.components;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import lycan.components.Component;
import lycan.components.Entity;
import lycan.phys.Phys;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import lycan.core.LG;
import lycan.phys.IsoBody;
import lycan.phys.BitmapDataIso;
import nape.geom.Mat23;
import flash.geom.Matrix;

interface PhysicsEntity extends Entity {
	public var physics:PhysicsComponent;
	@:relaxed public var x(get, set):Float;
	@:relaxed public var y(get, set):Float;
	@:relaxed public var moves(get, set):Bool;
	@:relaxed public var angle(get, set):Float;
	@:relaxed public var alive(get, set):Bool;
	@:relaxed public var exists(get, set):Bool;
	@:relaxed public var origin(get, set):FlxPoint;
	@:relaxed public var scale(get, set):FlxPoint;
	@:relaxed public var width(get, set):Float;
	@:relaxed public var height(get, set):Float;
}

class PhysicsComponent extends Component<PhysicsEntity> {
	public var body:Body;
	public var space(get, never):Space;
	private function get_space():Space return body.space;
	
	public var position(get, set):Vec2;
	private function get_position() return body.position;
	private function set_position(p:Vec2) return body.position = p;
	
	public var rotation(get, set):Float;
	private function get_rotation() return body.rotation;
	private function set_rotation(v:Float) return body.rotation = v;
	
	public var rotationDeg(get, set):Float;
	private function get_rotationDeg():Float return body.rotation * FlxAngle.TO_DEG;
	private function set_rotationDeg(angleDeg:Float):Float {body.rotation = angleDeg * FlxAngle.TO_RAD; return angleDeg;}
	
	public var enabled(default, set):Bool = false;
	
	public var offset:FlxPoint;
	
	public var linearDrag:Float = 1;
	public var angularDrag:Float = 1;
	
	public var rotateEntity:Bool = true;
	
	public var enableUpdate(default, set):Bool;
	
	public function new(entity:PhysicsEntity) {
		super(entity);
	}
	
	public function init(?bodyType:BodyType, createRectBody:Bool = true, enabled:Bool = true, enableUpdate:Bool = true) {
		if (bodyType == null) bodyType = BodyType.DYNAMIC;
		
		body = new Body(bodyType);
		offset = FlxPoint.get();
		
		if (createRectBody) {
			createRectangularBody(0, 0, bodyType);
		}
		
		body.userData.entity = entity;
		
		this.enabled = enabled;
		this.enableUpdate = enableUpdate;
	}
	
	private function set_enableUpdate(val:Bool):Bool {
		if (this.enableUpdate == val) return val;
		this.enableUpdate = val;
		if (val) {
			LG.lateUpdate.add(update);
		} else {
			LG.lateUpdate.remove(update);
		}
		return val;
	}
	
	@:append("destroy")
	public function destroy():Void {
		destroyPhysObjects();
		enableUpdate = false;
		offset = FlxDestroyUtil.put(offset);
	}

	public function update(dt:Float):Void {
		if (!entity.entity_exists) return;
		
		if (body != null && entity.entity_moves) {
			updatePhysObjects();
		}
	}
	
	// TODO bad
	@:append("kill")
	public function onKill():Void {
		if (body != null) body.space = null;
	}
	
	@:append("revive")
	public function onRevive():Void {
		if (body != null) body.space = Phys.space;
	}
	
	public function addPremadeBody(newBody:Body):Void {
		if (body != null) {
			destroyPhysObjects();
		}
		
		newBody.position.x = entity.entity_x;
		newBody.position.y = entity.entity_y;
		setBody(newBody);
		setBodyMaterial();
	}
	
	public function createCircularBody(radius:Float = 16, ?type:BodyType):Void {
		if (body != null) destroyPhysObjects();
		if (Std.is(entity, FlxSprite)) {
			var entity:FlxSprite = cast entity;
			
			entity.centerOffsets(false);
			setBody(new Body(type != null ? type : BodyType.DYNAMIC, Vec2.weak(entity.x, entity.y)));
			body.shapes.add(new Circle(radius));
			
			setBodyMaterial();
		}
	}
	
	public function createRectangularBody(width:Float = 0, height:Float = 0, ?type:BodyType):Void {
		if (body != null) destroyPhysObjects();
		
		if (Std.is(entity, FlxSprite)) {
			var entity:FlxSprite = cast this.entity;
			if (width <= 0) {
				width = entity.width;
			}
			if (height <= 0) {
				height = entity.height;
			}
			
			entity.centerOffsets(false);
			
			// Todo check for transform instead when such a thing exists
			setBody(new Body(type != null ? type : BodyType.DYNAMIC, Vec2.weak(entity.x, entity.y)));
			body.shapes.add(new Polygon(Polygon.box(width, height)));
			
			setBodyMaterial();
		}
	}
	
	public function createBodyFromBitmap(?bmp:BitmapData, alphaThreshold:Float = 0x80, ?grid:Vec2, quality:Int = 2, simplification:Float = 1.5):Void {
		if (body != null) destroyPhysObjects();
		if (bmp == null && Std.is(entity, FlxSprite)) {
			var spr:FlxSprite = cast entity;
			bmp = spr.pixels;
		}
		
		var iso = new BitmapDataIso(bmp, alphaThreshold);
		var isoFunc = #if flash iso #else (x:Float, y:Float)->{return iso.iso(x, y);}#end;
		var body:Body = IsoBody.run(isoFunc, iso.bounds, grid, quality, simplification);
		addPremadeBody(body);
		setBodyMaterial();
		var s:FlxSprite = cast entity;
		var o:Vec2 = body.userData.graphicOffset;
		offset.set(o.x, o.y);
		s.origin.set(-o.x, -o.y);
		
		body.userData.entity = entity;
	}
	
	/**
	 * Translates shapes such that origin becomes specified position
	 * 
	 * @param x X position of the origin from top left of bounds
	 * @param y Y Position of the origin from top left of bounds
	 */
	public function setBodyOrigin(x:Float, y:Float):Void {
		var pos:Vec2 = body.worldPointToLocal(Vec2.weak(body.bounds.x, body.bounds.y));
		body.translateShapes(Vec2.weak(-x - pos.x, -y - pos.y));
		pos.dispose();
	}
	
	public function updateEntityOrigin():Void {
		var pos:Vec2 = body.worldPointToLocal(Vec2.weak(body.bounds.x, body.bounds.y));
		entity.entity_origin.set(-pos.x, -pos.y);
		pos.dispose();
	}
	
	public function flipShapes(flipX:Bool = true, flipY:Bool = false):Void {
		var m = new Matrix();
		m.identity();
		m.scale(flipX ? -1 : 1, flipY ? -1 : 1);
		var mat = Mat23.fromMatrix(m);
		body.transformShapes(mat);
	}
	
	public function setBodyMaterial(elasticity:Float = 0, dynamicFriction:Float = 0.2, staticFriction:Float = 0.4,
		density:Float = 1, rotationFriction:Float = 0.001):Void
	{
		if (body == null) return;
		body.setShapeMaterials(new Material(elasticity, dynamicFriction, staticFriction, density, rotationFriction));
	}
	
	public function destroyPhysObjects():Void {
		if (body != null) {
			if (space != null) {
				space.bodies.remove(body);
			}
			body = null;
		}
	}
	
	//TODO from old flixel. origin is not correct
	public function snapEntityToBody():Void {
		entity.entity_x = position.x - entity.entity_origin.x;
		entity.entity_y = position.y - entity.entity_origin.y;
		
		if (Phys.floorPos) {
			entity.entity_x = Math.floor(entity.entity_x);
			entity.entity_y = Math.floor(entity.entity_y);
		}
		
		if (body.allowRotation && rotateEntity) {
			entity.entity_angle = body.rotation * FlxAngle.TO_DEG;
		}
	}
	
	public function snapBodyToEntity(?body:Body, disableWhileSnapping:Bool = true):Void {
		if (body == null) body = this.body;
		var oldSpace = body.space;
		if (disableWhileSnapping) body.space = null;
		body.position.x = entity.entity_x + entity.entity_origin.x;
		body.position.y = entity.entity_y + entity.entity_origin.y;
		
		if (Phys.floorPos) {
			body.position.x = Math.floor(body.position.x);
			body.position.y = Math.floor(body.position.y);
		}
		
		if (body.allowRotation) {
			body.rotate(Vec2.weak(entity.entity_x + entity.entity_width / 2, entity.entity_y + entity.entity_height / 2), entity.entity_angle * FlxAngle.TO_RAD);
		}
		body.space = oldSpace;
	}
	
	public inline function setDrag(linearDrag:Float = 1, angularDrag:Float = 1):Void {
		this.linearDrag	= linearDrag;
		this.angularDrag = angularDrag;
	}
	
	/**
	 * Updates physics FlxSprite graphics to follow this sprite physics object, called at the end of update().
	 * Things that are updated: Position, angle, angular and linear drag.
	 */
	private function updatePhysObjects():Void {
		snapEntityToBody();
		
		// Applies custom physics drag.
		if (linearDrag < 1 || angularDrag < 1) {
			// body.angularVel *= angularDrag;
			// body.velocity.x *= linearDrag;
			// body.velocity.y *= linearDrag;
		}
	}
	
	public function setBody(body:Body):Void {
		this.body = body;
		this.enabled = enabled;
	}
	
	private function set_enabled(value:Bool):Bool {
		if (body != null)
			body.space = value ? Phys.space : null;
		return enabled = value;
	}
	
}