package lycan.world.components;

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

import flixel.FlxSprite;
import flixel.FlxObject;

interface PhysicsEntity extends Entity {
	public var physics:PhysicsComponent;
	@:relaxed public var x(get, set):Float;
	@:relaxed public var y(get, set):Float;
	@:relaxed public var moves(get, set):Bool;
	@:relaxed public var angle(get, set):Float;
}

class PhysicsComponent extends Component<PhysicsEntity> {
	public var body:B2Body;
	public var world(get, never):B2World;
	private function get_world():B2World return body.getWorld();
	
	public var enabled(default, set):Bool = false;
	public var offset:FlxPoint;
	
	/** Internal var to update body.velocity.x and body.velocity.y. 1 = no drag */
	private var _linearDrag:Float = 1;
	/** Internal var to update body.angularVel. 1 = no drag */
	private var _angularDrag:Float = 1;
	
	public function init(?bodyType:B2BodyType, createRectBody:Bool = true, enabled:Bool = true) {
		if (bodyType == null) bodyType = B2BodyType.DYNAMIC_BODY;
		
		var bd:B2BodyDef;
		body = Box2D.world.createBody(bd);
		
		offset = FlxPoint.get();
		
		if (createRectBody) {
			this.createRectangularBody();
		}
		this.enabled = enabled;
	}
	
	public function destroy():Void {
		destroyPhysObjects();
		offset = FlxDestroyUtil.put(offset);
	}

	public function update():Void {
		if (body != null && entity.entity_moves) {
			updatePhysObjects();
		}
	}

	public function onKill():Void {
		if (body != null) {
			
	}
	
	public function onRevive():Void {
		if (body != null) {
			Box2D.world.createBody
		}
	}
	
	/**
	 * Makes it easier to add a physics body of your own to this sprite by setting its position,
	 * space and material for you.
	 *
	 * @param	NewBody 	The new physics body replacing the old one.
	 */
	public function addPremadeBody(newBody:B2Body):Void {
		if (body != null) {
			destroyPhysObjects();
		}
		
		NewBody.position.x = entity.entity_x;
		NewBody.position.y = entity.entity_y;
		setBody(NewBody);
		setBodyMaterial();
	}
	
	public function createCircularBody(Radius:Float = 16, ?_Type:BodyType):Void {
		trace("Create circular body");
		if (Std.is(entity, FlxSprite)) {
			trace("Is a sprite");
			var entity:FlxSprite = cast entity;
			
			if (body != null) {
				destroyPhysObjects();
			}
			
			entity.centerOffsets(false);
			setBody(new Body(_Type != null ? _Type : BodyType.DYNAMIC, Vec2.weak(entity.x, entity.y)));
			body.shapes.add(new Circle(Radius));
			
			setBodyMaterial();
		}
	}
	
	public function createRectangularBody(Width:Float = 0, Height:Float = 0, ?_Type:BodyType):Void {
		if (body != null) {
			destroyPhysObjects();
		}
		
		if (Std.is(entity, FlxSprite)) {
			var entity:FlxSprite = cast this.entity;
			if (Width <= 0) {
				Width = entity.frameWidth * entity.scale.x;
			}
			if (Height <= 0) {
				Height = entity.frameHeight * entity.scale.y;
			}
			
			entity.centerOffsets(false);
			
			// Todo check for transform instead when such a thing exists
			setBody(new Body(_Type != null ? _Type : BodyType.DYNAMIC, Vec2.weak(entity.x, entity.y)));
			body.shapes.add(new Polygon(Polygon.box(Width, Height)));
			
			setBodyMaterial();
		}
	}
	
	public function setBodyMaterial(Elasticity:Float = 1, DynamicFriction:Float = 0.2, StaticFriction:Float = 0.4, Density:Float = 1, RotationFriction:Float = 0.001):Void {
		if (body == null)
			return;
		
		body.setShapeMaterials(new Material(Elasticity, DynamicFriction, StaticFriction, Density, RotationFriction));
	}
	
	public function destroyPhysObjects():Void {
		if (body != null) {
			if (NapeSpace.space != null)
				NapeSpace.space.bodies.remove(body);
			body = null;
		}
	}
	
	public inline function setDrag(LinearDrag:Float = 1, AngularDrag:Float = 1):Void {
		_linearDrag	= LinearDrag;
		_angularDrag = AngularDrag;
	}
	
	public function setBody(body:Body):Void {
		this.body = body;
		this.enabled = enabled;//TODO make it so this isn't necessary
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
		if (_linearDrag < 1 || _angularDrag < 1) {
			body.angularVel *= _angularDrag;
			body.velocity.x *= _linearDrag;
			body.velocity.y *= _linearDrag;
		}
	}
	
	//TODO from old flixel. origin is not correct
	private function updatePosition():Void {
		if (!Std.is(entity, FlxSprite)) return;
		var entity:FlxSprite = cast entity;
		entity.x = body.position.x - entity.origin.x * entity.scale.x;
		entity.y = body.position.y - entity.origin.y * entity.scale.y;
	}
	
	//TODO remove old body?
	private function set_enabled(Value:Bool):Bool {
		if (body != null)
			body.space = Value ? NapeSpace.space : null;
		return enabled = Value;
	}
	
	public function setPosition(X:Float = 0, Y:Float = 0):Void {
		body.position.x = X;
		body.position.y = Y;
		
		updatePosition();
	}
	
	override public function set_entity(entity:PhysicsEntity):PhysicsEntity {
		this.entity = entity;
		//autoSub(FlxG.signals.preDraw, update);
		//autoSub(entity.killed, onKill);
		//autoSub(entity.revived, onRevive);
		return entity;
	}
}