package lycan.world.components;

import flixel.FlxBasic.FlxType;
import nape.geom.ConvexResult;
import nape.phys.Body;
import flixel.math.FlxMath;
import lycan.phys.PlatformerPhysics;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.shape.Circle;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.util.GraphicUtil;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import nape.shape.Shape;
import nape.phys.BodyType;
import lycan.phys.Phys;
import lycan.components.Entity;
import lycan.components.Component;
import flixel.FlxObject;
import nape.constraint.LineJoint;
import flixel.FlxSprite;

interface CharacterController extends Entity {
	public var characterController:CharacterControllerComponent;
	public var physics:PhysicsComponent;
	public var groundable:GroundableComponent;
}

@:tink
class CharacterControllerComponent extends Component<CharacterController> {
	@:forward var _object:FlxSprite;
	@:calc var physics:PhysicsComponent = entity.physics;
	
	public var targetMoveVel:Float = 0;
	public var currentMoveVel:Float = 0;
	public var moveAcceleration:Float = 0.4;
	public var stopAcceleration:Float = 0.4;
	public var minMoveVel:Float = 20;
	@:calc public var isMoving:Bool = targetMoveVel != 0;
	
	public var jumpSpeed:Float = -900;
	public var runSpeed:Float = 600;
	public var maxJumps:Int = 2;
	public var maxJumpVelY:Float = 500;
	public var airDrag:Float = 5000;
	
	public var dropThrough:Bool = false;
	
	/** Indicates how in control the character is. Applies high drag while in air. */
	public var hasControl:Bool;
	public var currentJumps:Int;
	public var canJump:Bool;
	
	// State
	public var isSliding:Bool = false;
	
	//var movingPlatforms:Array<MovingPlatform>;
	//var currentMovingPlatform:MovingPlatform;
	
	public var anchor:Body;
	public var anchorJoint:LineJoint;
	public var bodyShape:Shape;
	public var feetShape:Shape;
	
	public function new(entity:CharacterController) {
		super(entity);
		
		_object = cast entity;
		targetMoveVel = 0;
	}
	
	public function init(?width:Float, ?height:Float) {
		if (width == null) width = _object.width;
		if (height == null) height = _object.height;
		
		physics.init(BodyType.DYNAMIC, false);
		physics.body.position.setxy(x, y);
		physics.body.allowRotation = false;
		feetShape = new Circle(width / 2, Vec2.weak(0, (height - width) / 2));
		bodyShape = new Polygon(Polygon.rect(-width / 2, -height / 2, width, height - width / 2));
		physics.body.shapes.add(feetShape);
		physics.body.shapes.add(bodyShape);
		physics.setBodyMaterial();
		physics.body.group = PlatformerPhysics.overlappingObjectGroup;
		
		physics.body.isBullet = true;
		
		anchor = new Body(BodyType.STATIC);
		anchor.space = physics.body.space;
		
		anchorJoint = new LineJoint(anchor, physics.body, anchor.worldPointToLocal(Vec2.get(0.0, 0.0)),
			physics.body.worldPointToLocal(Vec2.get(0.0, 0.0)), Vec2.weak(0.0, 1.0), Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		anchorJoint.stiff = false;
		anchorJoint.maxError = 0.0;		
		anchorJoint.space = physics.body.space;
		
		hasControl = true;
		currentJumps = 0;
		
		physics.body.cbTypes.add(PlatformerPhysics.characterType);
		physics.body.cbTypes.add(PlatformerPhysics.groundableType);
	}
	
	public function move() {
		isSliding = false;
		currentMoveVel -= moveAcceleration * (currentMoveVel - targetMoveVel);
		
		if (Math.abs(currentMoveVel) < minMoveVel) {
			currentMoveVel = 0;
		}
		
		facing = currentMoveVel < 0 ? FlxObject.LEFT : FlxObject.RIGHT;
		anchor.kinematicVel.x = currentMoveVel;
	}
	
	//TODO destroy
	
	@:prepend("update")
	public function update(dt:Float):Void {
		var body:Body = physics.body;
		var groundable:GroundableComponent = entity.groundable;
		
		//TODO test this attempt to only anchor if we are trying to move
		//TODO stop is duplicating airdrag functionality! oops
		anchorJoint.active = hasControl && Math.abs(currentMoveVel) > 0;
		
		// Compute groundedness
		// Clear previous grounds
		// TODO make this the proper method instead of a quick hack for LD readiness
		var oldVel:Vec2 = body.velocity.copy(true);
		body.velocity.setxy(0, 1);
		body.position.y--;
		var result:ConvexResult = Phys.space.convexCast(feetShape, 1, false);
		if (result != null && Math.abs(result.normal.angle * FlxAngle.TO_DEG + 90)  <= groundable.groundedAngleLimit) {
			entity.groundable.add(result.shape.body.userData.entity);
		}
		body.position.y++;
		body.velocity.set(oldVel);
		
		
		var isGrounded:Bool = groundable.isGrounded;
		
		// Ground sucking
		// Dont apply to very edges (like in Chris' original method)
		// TODO replace groundedness with something like this?
		// TODO is this a bad method? Fires leave listeners that shouldnt...
		// TODO no friction on moving platforms that are moving down... we need friction! (or specil moving platforms)
		if (groundable.wasGrounded && !isGrounded) {
			var oldVel:Vec2 = body.velocity.copy(true);
			body.velocity.setxy(0, 10 * 60);//TODO customisable
			body.position.y--;
			var result:ConvexResult = Phys.space.convexCast(feetShape, 1/60, false);
			if (result != null && Math.abs(result.normal.angle * FlxAngle.TO_DEG + 90)  <= entity.groundable.groundedAngleLimit) {
				body.integrate(result.toi);
				entity.groundable.add(result.shape.body.userData.entity);
			} else {
				body.position.y++;
			}
			body.velocity.set(oldVel);
		}
		
		// Moving Left/Right
		var leftPress = FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT]);
		var rightPress = FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT]);
		if (leftPress != rightPress) {
			targetMoveVel = leftPress ? -runSpeed : runSpeed;
			move();
		} else {
			if (Math.abs(currentMoveVel) > 0) stop();
		}
		
		// Ground friction
		var groundable:GroundableComponent = entity.groundable;
		FlxG.watch.addQuick("grounded", groundable.isGrounded);
		if (groundable.isGrounded && !isMoving) {
			feetShape.material.dynamicFriction = 100;
			feetShape.material.staticFriction = 100;
		} else {
			feetShape.material.dynamicFriction = 0;
			feetShape.material.staticFriction = 0;
		}
		FlxG.watch.addQuick("friction", feetShape.material.dynamicFriction);
		
		
		if (groundable.isGrounded) {
			currentJumps = 0;
			canJump = true;
		}
		
		if (currentJumps >= maxJumps || (body.velocity.y > maxJumpVelY && !groundable.isGrounded)) {
			canJump = false;
		}
		
		
		if (FlxG.keys.anyJustPressed([FlxKey.W, FlxKey.UP])) {
			if (canJump) {
				currentJumps++;
				physics.body.velocity.y = jumpSpeed;
			}
		}
		
		dropThrough = false;	
		if (FlxG.keys.anyPressed([FlxKey.S, FlxKey.DOWN])) {
			dropThrough = true;
		}
	}
	
	public function stop() {
		targetMoveVel = 0;
		// TODO from Chris' controller, but doesn't account for dts
		currentMoveVel -= stopAcceleration * currentMoveVel;
		
		if (Math.abs(currentMoveVel) < minMoveVel) {
			currentMoveVel = 0;
			isSliding = false;
		}
		
		anchor.kinematicVel.x = currentMoveVel;
	}
	
	public function run() {
		
	}
	
	public function jump() {
		
	}
}