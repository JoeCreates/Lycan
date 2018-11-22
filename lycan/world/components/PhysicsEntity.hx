package lycan.world.components;

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

interface PhysicsEntity extends Entity {
	public var physics:PhysicsComponent;
	@:relaxed public var x(get, set):Float;
	@:relaxed public var y(get, set):Float;
	@:relaxed public var moves(get, set):Bool;
	@:relaxed public var angle(get, set):Float;
	@:relaxed public var alive(get, set):Bool;
	@:relaxed public var origin(get, set):FlxPoint;
	@:relaxed public var scale(get, set):FlxPoint;
	@:relaxed public var width(get, set):Float;
	@:relaxed public var height(get, set):Float;
}

@:tink class PhysicsComponent extends Component<PhysicsEntity> {
	@:forward(position, rotation) public var body:Body;
	public var space(get, never):Space;
	private function get_space():Space return body.space;
	
	public var rotationDeg(get, set):Float;
	private function get_rotationDeg():Float return body.rotation * FlxAngle.TO_DEG;
	private function set_rotationDeg(angleDeg:Float):Float {body.rotation = angleDeg * FlxAngle.TO_RAD; return angleDeg;}
	
	public var enabled(default, set):Bool = false;
	
	public var offset:FlxPoint;
	
	private var linearDrag:Float = 1;
	private var angularDrag:Float = 1;
	
	public function new(entity:PhysicsEntity) {
		super(entity);
	}
	
	public function init(?bodyType:BodyType, createRectBody:Bool = true, enabled:Bool = true) {
		if (bodyType == null) bodyType = BodyType.DYNAMIC;
		
		body = new Body(bodyType);
		body.space = Phys.space;
		offset = FlxPoint.get();
		
		if (createRectBody) {
			createRectangularBody();
		}
		this.enabled = enabled;
		LG.lateUpdate.add(update);
	}
	
	@:append("destroy")
	public function destroy():Void {
		destroyPhysObjects();
		LG.lateUpdate.remove(update);
		offset = FlxDestroyUtil.put(offset);
	}

	public function update(dt:Float):Void {
		if (!entity.entity_alive) return;
		
		if (body != null && entity.entity_moves) {
			updatePhysObjects();
		}
	}
	
	@:prepend("kill")
	public function onKill():Void {
		if (body != null) body.space = null;
	}
	
	@:prepend("revive")
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
				width = entity.frameWidth * entity.scale.x;
			}
			if (height <= 0) {
				height = entity.frameHeight * entity.scale.y;
			}
			
			entity.centerOffsets(false);
			
			// Todo check for transform instead when such a thing exists
			setBody(new Body(type != null ? type : BodyType.DYNAMIC, Vec2.weak(entity.x, entity.y)));
			body.shapes.add(new Polygon(Polygon.box(width, height)));
			
			setBodyMaterial();
		}
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
	public function updatePosition():Void {
		entity.entity_x = Math.floor(position.x - entity.entity_origin.x * entity.entity_scale.x);
		entity.entity_y = Math.floor(position.y - entity.entity_origin.y * entity.entity_scale.y);
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
		updatePosition();
		
		if (body.allowRotation) {
			entity.entity_angle = body.rotation * FlxAngle.TO_DEG;
		}
		
		// Applies custom physics drag.
		if (linearDrag < 1 || angularDrag < 1) {
			body.angularVel *= angularDrag;
			body.velocity.x *= linearDrag;
			body.velocity.y *= linearDrag;
		}
	}
	
	public function setBody(body:Body):Void {
		this.body = body;
		this.enabled = enabled;//TODO make it so this isn't necessary
	}
	
	private function set_enabled(value:Bool):Bool {
		if (body != null)
			body.space = value ? Phys.space : null;
		return enabled = value;
	}
	
}