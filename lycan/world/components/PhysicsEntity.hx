package lycan.world.components;

import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2World;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import lycan.components.Component;
import lycan.components.Entity;
import box2D.collision.shapes.B2MassData;

import flixel.FlxSprite;
import flixel.FlxObject;

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
	public var offset:FlxPoint;
	
	/** Helper vec2 to reduce object instantiation */
	private static var _vec2:B2Vec2 = new B2Vec2();
	
	/** Multiplier on velocity per step. 1 = no drag */
	public var linearDamping:Float = 1;
	/** Multiplier on angular velocity on step. 1 = no drag */
	public var angularDamping:Float = 1;
	
	public function new(entity:PhysicsEntity) {
		super(entity);
	}
	
	public function init(?bodyType:B2BodyType, createRectShape:Bool = true, enabled:Bool = true) {
		if (bodyType == null) bodyType = B2BodyType.DYNAMIC_BODY;
		
		var bd:B2BodyDef;
		bd = new B2BodyDef();
		bd.type = bodyType;
		bd.position.set(entity.entity_x / Box2D.pixelsPerMeter, entity.entity_y / Box2D.pixelsPerMeter);
		bd.userData = this;
		body = Box2D.world.createBody(bd);
		
		offset = FlxPoint.get();
		
		if (createRectShape) {
			this.createRectangularShape(entity.entity_width, entity.entity_height);
		}
		//this.enabled = enabled;
		
		FlxG.signals.postUpdate.add(update);
	}
	
	@:append("destroy")
	public function destroy():Void {
		destroyPhysObjects();
		offset = FlxDestroyUtil.put(offset);
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
	
	/**
	 * Makes it easier to add a physics body of your own to this sprite by setting its position,
	 * space and material for you.
	 *
	 * @param	NewBody 	The new physics body replacing the old one.
	 */
	//public function addPremadeBody(newBody:B2Body):Void {
		//if (body != null) {
			//destroyPhysObjects();
		//}
		//
		//NewBody.position.x = entity.entity_x;
		//NewBody.position.y = entity.entity_y;
		//setBody(NewBody);
		//setBodyMaterial();
	//}
	
	public function createCircularShape(radius:Float = 16, ?type:B2BodyType):Void {
		//trace("Create circular body");
		//if (Std.is(entity, FlxSprite)) {
			//trace("Is a sprite");
			//var entity:FlxSprite = cast entity;
			//
			//if (body != null) {
				//destroyPhysObjects();
			//}
			//
			//entity.centerOffsets(false);
			//setBody(new Body(_Type != null ? _Type : BodyType.DYNAMIC, Vec2.weak(entity.x, entity.y)));
			//body.shapes.add(new Circle(Radius));
			//
			//setBodyMaterial();
		//}
	}
	
	public function createRectangularShape(pixelWidth:Float = 0, pixelHeight:Float = 0):Void {
		var rect = new B2PolygonShape();
		rect.setAsBox(pixelWidth / Box2D.pixelsPerMeter * 0.5, pixelHeight / Box2D.pixelsPerMeter * 0.5);
		body.createFixture2(rect);
		
		//if (body != null) {
			//destroyPhysObjects();
		//}
		//
		//if (Std.is(entity, FlxSprite)) {
			//var entity:FlxSprite = cast this.entity;
			//if (Width <= 0) {
				//Width = entity.frameWidth * entity.scale.x;
			//}
			//if (Height <= 0) {
				//Height = entity.frameHeight * entity.scale.y;
			//}
			//
			//entity.centerOffsets(false);
			//
			//// Todo check for transform instead when such a thing exists
			//setBody(new Body(_Type != null ? _Type : BodyType.DYNAMIC, Vec2.weak(entity.x, entity.y)));
			//body.shapes.add(new Polygon(Polygon.box(Width, Height)));
			//
			//setBodyMaterial();
		//}
	}
	
	public function setBodyMaterial(Elasticity:Float = 1, DynamicFriction:Float = 0.2, StaticFriction:Float = 0.4, Density:Float = 1, RotationFriction:Float = 0.001):Void {
		if (body == null)
			return;
		
		//body.setShapeMaterials(new Material(Elasticity, DynamicFriction, StaticFriction, Density, RotationFriction));
	}
	
	public function destroyPhysObjects():Void {
		if (body != null) {
			if (world != null) {
				world.destroyBody(body);
			}
			body = null;
		}
	}
	
	/** Update FlxSprite based on physics body and apply damping */
	private function updatePhysObjects():Void {
		updatePosition();
		
		if (!body.isFixedRotation()) entity.entity_angle = angleDeg;
		
		// Applies custom physics drag.
		if (angularDamping < 1) body.setAngularVelocity(body.getAngularVelocity() * angularDamping);
		if (linearDamping < 1) body.getLinearVelocity().multiply(linearDamping);//TODO does this work?
	}
	
	//TODO from old flixel. origin is not correct
	private function updatePosition():Void {
		if (!Std.is(entity, FlxSprite)) return;
		
		entity.entity_x = x * Box2D.pixelsPerMeter - entity.entity_origin.x * entity.entity_scale.x;
		entity.entity_y = y * Box2D.pixelsPerMeter - entity.entity_origin.y * entity.entity_scale.y;
	}
	
	// TODO enable/disable? :(
	
	public function setPixelPosition(x:Float = 0, y:Float = 0):Void {
		body.setPosition(new B2Vec2(x / Box2D.pixelsPerMeter, y / Box2D.pixelsPerMeter));
		updatePosition();
	}
	
	public static function vec2(x:Float, y:Float):B2Vec2 {
		_vec2.set(x, y);
		return _vec2;
	}
}