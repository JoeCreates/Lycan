package lycan.world.components;

import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import lycan.components.Component;
import lycan.components.Entity;
import lycan.phys.Phys;

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

class PhysicsComponent extends Component<PhysicsEntity> {
	public var body:B2Body;
	public var world(get, never):B2World;
	private function get_world():B2World return body.getWorld();
	
	public var x(get, set):Float;
	private function get_x():Float return body.getPosition().x;
	private function set_x(x:Float):Float return body.getPosition().x = x;
	public var y(get, set):Float;
	private function get_y():Float return body.getPosition().y;
	private function set_y(y:Float):Float return body.getPosition().y = y;
	public var angle(get, set):Float;
	private function get_angle():Float return body.getAngle();
	private function set_angle(angle:Float):Float {body.setAngle(angle); return angle;}
	public var angleDeg(get, set):Float;
	private function get_angleDeg():Float return body.getAngle() * FlxAngle.TO_DEG;
	private function set_angleDeg(angleDeg:Float):Float {body.setAngle(angleDeg * FlxAngle.TO_RAD); return angleDeg;}
	
	//public var enabled(default, set):Bool = false;
	//private function set_enabled(enabled:Bool):Bool { 
	// TODO
	//this.enabled = enabled;
	//return enabled; 
	//}
	
	/** Helper vec2 to reduce object instantiation */
	private static var _vec2:B2Vec2 = new B2Vec2();
	
	public var linearVelocityX(get, set):Float;
	private function get_linearVelocityX():Float return body.getLinearVelocity().x;
	private function set_linearVelocityX(vel:Float):Float { body.setLinearVelocity(vec2(vel, body.getLinearVelocity().y)); return vel; }
	
	public var linearVelocityY(get, set):Float;
	private function get_linearVelocityY():Float return body.getLinearVelocity().y;
	private function set_linearVelocityY(vel:Float):Float { body.setLinearVelocity(vec2(body.getLinearVelocity().x, vel)); return vel; }
	
	/** Multiplier on velocity per step. 0 = no drag */
	public var linearDamping(get, set):Float;
	public function get_linearDamping():Float return body.getLinearDamping();
	public function set_linearDamping(damping:Float):Float { body.setLinearDamping(damping); return damping; }
	
	public var angularVelocity(get, set):Float;
	public function get_angularVelocity():Float return body.getAngularVelocity();
	public function set_angularVelocity(vel:Float):Float { body.setAngularVelocity(vel); return vel; }
	
	/** Multiplier on angular velocity on step. 0 = no drag */
	public var angularDamping(get, set):Float;
	public function get_angularDamping():Float return body.getAngularDamping();
	public function set_angularDamping(damping:Float):Float { body.setAngularDamping(damping); return damping; }
	
	public var bodyType(get, set):B2BodyType;
	public function get_bodyType():B2BodyType return body.getType();
	public function set_bodyType(type:B2BodyType) { body.setType(type); return type; }
	
	public var fixedRotation(get, set):Bool;
	public function get_fixedRotation():Bool return body.isFixedRotation();
	public function set_fixedRotation(fixed:Bool) { body.setFixedRotation(fixed); return fixed; }
	
	public var sleepingAllowed(get, set):Bool;
	public function get_sleepingAllowed():Bool { return body.isSleepingAllowed(); }
	public function set_sleepingAllowed(sleep:Bool) { body.setSleepingAllowed(sleep); return sleep; }
	
	public function new(entity:PhysicsEntity) {
		super(entity);
	}
	
	public function init(?bodyType:B2BodyType, createRectShape:Bool = true, enabled:Bool = true) {
		if (bodyType == null) bodyType = B2BodyType.DYNAMIC_BODY;
		
		var bd:B2BodyDef = new B2BodyDef();
		bd.type = bodyType;
		bd.position.set(entity.entity_x / Phys.pixelsPerMeter, entity.entity_y / Phys.pixelsPerMeter);
		bd.userData = this;
		bd.bullet = false;
		body = Phys.world.createBody(bd);
		
		setPixelPosition(entity.entity_x, entity.entity_y);
		
		//this.enabled = enabled;
		
		FlxG.signals.postUpdate.add(update);
	}
	
	public function initWithRectShape(?bodyType:B2BodyType, enabled:Bool = true, density:Float = 0) {
		init(bodyType, enabled);
		this.addRectangularShape(entity.entity_width, entity.entity_height, density);
	}
	
	@:append("destroy")
	public function destroy():Void {
		destroyPhysObjects();
		FlxG.signals.postUpdate.remove(update);
	}

	public function update():Void {
		if (!entity.entity_alive) return;
		
		if (body != null && entity.entity_moves) {
			updatePhysObjects();
		}
	}
	
	@:prepend("kill")
	public function onKill():Void {
		//TODO 
	}
	
	@:prepend("revive")
	public function onRevive():Void {
		if (body != null) {
			//Box2D.world.createBody
			//TODO
		}
	}
	
	public function addFixture(shape:B2Shape, density:Float, filter:B2FilterData, friction:Float, isSensor:Bool, restitution:Float, userData:Dynamic):B2Fixture {
		var def = new B2FixtureDef();
		def.shape = shape;
		def.density = density;
		def.filter = filter;
		def.friction = friction;
		def.isSensor = isSensor;
		def.restitution = restitution;
		def.userData = userData;
		return body.createFixture(def);
	}
	
	public function addRectangularShape(pixelWidth:Float, pixelHeight:Float, density:Float = 0):B2Fixture {
		// TODO?
		//if (pixelWidth <= 0) {
		//	pixelWidth = entity.entity_frameWidth * entity.entity_scale.x;
		//}
		//if (pixelHeight <= 0) {
		//	pixelHeight = entity.entity_frameHeight * entity.entity_scale.y;
		//}
		//entity.centerOffsets(false);
		
		var rect = Phys.createRectangularShape(pixelWidth, pixelHeight);
		var fixture = body.createFixture2(rect, density);
		return fixture;
	}
	
	public function addRectangularShapeAdv(pixelWidth:Float, pixelHeight:Float, pixelPositionX:Float, pixelPositionY:Float, density:Float, filter:B2FilterData, friction:Float, isSensor:Bool, restitution:Float, userData:Dynamic):B2Fixture {
		var rect = Phys.createRectangularShape(pixelWidth, pixelHeight, pixelPositionX, pixelPositionY);
		return addFixture(rect, density, filter, friction, isSensor, restitution, userData);
	}
	
	public function addCircleShapeAdv(pixelRadius:Float, pixelPositionX:Float, pixelPositionY:Float, density:Float, filter:B2FilterData, friction:Float, isSensor:Bool, restitution:Float, userData:Dynamic):B2Fixture {
		var circle = Phys.createCircleShape(pixelRadius, pixelPositionX, pixelPositionY);
		return addFixture(circle, density, filter, friction, isSensor, restitution, userData);
	}
	
	public function destroyPhysObjects():Void {
		if (body != null) {
			if (world != null) {
				world.destroyBody(body);
			}
			body = null;
		}
	}
	
	/** Update FlxSprite based on physics body */
	private function updatePhysObjects():Void {
		updatePosition();
		
		if (!body.isFixedRotation()) {
			entity.entity_angle = angleDeg;
		}
	}
	
	//TODO from old flixel. origin is not correct
	private function updatePosition():Void {
		entity.entity_x = x * Phys.pixelsPerMeter - entity.entity_origin.x * entity.entity_scale.x;
		entity.entity_y = y * Phys.pixelsPerMeter - entity.entity_origin.y * entity.entity_scale.y;
	}
	
	// TODO enable/disable? :(
	
	public function setPixelPosition(x:Float = 0, y:Float = 0):Void {
		body.setPosition(vec2(x / Phys.pixelsPerMeter, y / Phys.pixelsPerMeter));
		updatePosition();
	}
	
	private static inline function vec2(x:Float, y:Float):B2Vec2 {
		_vec2.set(x, y);
		return _vec2;
	}
}