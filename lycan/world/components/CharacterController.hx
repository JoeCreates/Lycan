package lycan.world.components;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionManager;
import nape.dynamics.InteractionFilter;
import flixel.FlxBasic.FlxType;
import nape.geom.ConvexResult;
import nape.geom.ConvexResultList;
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
import flixel.util.FlxSignal;

interface CharacterController extends Entity {	
	public var characterController:CharacterControllerComponent;
	public var physics:PhysicsComponent;
	public var groundable:GroundableComponent;
}

@:tink
class CharacterControllerComponent extends Component<CharacterController> {
	//TODO
	public static var onCharacterJump:FlxTypedSignal<CharacterController->Void> = new FlxTypedSignal<CharacterController->Void>();
	
	@:forward var _object:FlxSprite;
	@:calc var physics:PhysicsComponent = entity.physics;
	
	public var targetMoveVel:Float = 0;
	public var currentMoveVel:Float = 0;
	public var moveAcceleration:Float = 1;
	public var stopAcceleration:Float = 0.2;
	public var minMoveVel:Float = 20;
	@:calc public var isMoving:Bool = targetMoveVel != 0;
	
	public var jumpSpeed:Float = -900;
	public var runSpeed:Float = 600;
	public var maxJumps:Int = 2;
	public var maxJumpVelY:Float = 500;
	public var airDrag:Float = 90000;
	public var groundSuckDistance:Float = 4;
	public var enableHardTurn:Bool = true;
	
	public var dropThrough:Bool = false;
	
	/** Indicates how in control the character is. Applies high drag while in air. */
	public var hasControl(default, set):Bool;
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
	
	public var actionJump:Bool;
	public var actionLeft:Bool;
	public var actionRight:Bool;
	
	private var feetCastResutList:ConvexResultList;
	
	public function new(entity:CharacterController) {
		super(entity);
		
		_object = cast entity;
		targetMoveVel = 0;
		
		feetCastResutList = new ConvexResultList();
		
		resetActions();
	}
	
	public function init(?width:Float, ?height:Float) {
		if (width == null) width = _object.width;
		if (height == null) height = _object.height;
		
		physics.init(BodyType.DYNAMIC, false);
		physics.body.allowRotation = false;
		feetShape = new Circle(width / 2, Vec2.weak(0, (height - width) / 2));
		bodyShape = new Polygon(Polygon.rect(-(width / 2 - 0.3), -height / 2, width - 0.6, height - width / 2));
		physics.body.shapes.add(feetShape);
		physics.body.shapes.add(bodyShape);
		physics.setBodyMaterial(0, 0, 0.1);
		bodyShape.material = new Material(0, 0, 0, 1, 0);
		physics.body.group = PlatformerPhysics.overlappingObjectGroup;

		anchor = new Body(BodyType.STATIC);
		anchor.space = physics.body.space;
		
		anchorJoint = new LineJoint(anchor, physics.body, anchor.worldPointToLocal(Vec2.get(0.0, 0.0)),
			physics.body.worldPointToLocal(Vec2.get(0.0, 0.0)), Vec2.weak(0.0, 1.0), Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		anchorJoint.stiff = false;
		anchorJoint.maxError = 0.0;
		//TODO this *2 may be a problem for moving up slopes but seems to be the easiest way to increase accel for now
		anchorJoint.maxForce = runSpeed * 3 * physics.body.mass;		
		anchorJoint.space = physics.body.space;
		
		hasControl = true;
		currentJumps = 0;
		
		physics.body.cbTypes.add(PlatformerPhysics.characterType);
		physics.body.cbTypes.add(PlatformerPhysics.groundableType);
	}
	
	public function move() {
		isSliding = false;
		currentMoveVel += moveAcceleration * (targetMoveVel - currentMoveVel);
		
		if (Math.abs(currentMoveVel) < minMoveVel) {
			currentMoveVel = 0;
		}
		
		// If enableHardTurn is true, we make a hard stop if we would otherwise be slipping backward
		if (enableHardTurn && ((targetMoveVel > 0 && currentMoveVel < 0) || (targetMoveVel < 0 && currentMoveVel > 0))) {
			currentMoveVel = 0;
		}
		
		facing = currentMoveVel < 0 ? FlxObject.LEFT : FlxObject.RIGHT;
		anchor.kinematicVel.x = currentMoveVel;
		
		//TEST physics.body.applyImpulse(Vec2.weak(currentMoveVel / physics.body.mass), physics.body.position);
	}
	
	// @:append("destroy")
	// public function destroy() {
	// 	anchor.space = null;
	// 	anchorJoint.space = null;
	// 	_object = null;
	// }
	
	public function resetActions() {
		actionLeft = false;
		actionRight = false;
		actionJump = false;
	}
	
	@:append("kill")
	public function kill() {
		anchor.space = null;
		anchorJoint.space = null;
	}
	
	@:append("revive")
	public function revive() {
		anchor.space = entity.physics.body.space;
		anchorJoint.space = entity.physics.body.space;
	}
	
	@:append("destroy")
	public function destroy() {

	}
	
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
		
		feetCastResutList.clear();
		Phys.space.convexMultiCast(feetShape, 1, false, feetShape.filter, feetCastResutList);
		
		var grounded:Bool = false;
		feetCastResutList.foreach(function(result:ConvexResult) {
			if (!grounded && !result.shape.sensorEnabled && Math.abs(result.normal.angle * FlxAngle.TO_DEG + 90)  <= groundable.groundedAngleLimit) {
				entity.groundable.add(result.shape.body.userData.entity);
				grounded = true;
			}
		});
		
		body.position.y++;
		body.velocity.set(oldVel);
		
		
		var isGrounded:Bool = groundable.isGrounded;
		
		// Ground sucking
		// Dont apply to very edges (like in Chris' original method)
		// TODO replace groundedness with something like this?
		// TODO is this a bad method? Fires leave listeners that shouldnt...
		// TODO no friction on moving platforms that are moving down... we need friction! (or specil moving platforms)
		if (groundable.wasGrounded && !isGrounded) {//TODO hardcoded, better solution for side slipping
			var oldVel:Vec2 = body.velocity.copy(true);
			body.velocity.setxy(0, groundSuckDistance * 60);//TODO customisable
			body.position.y--;
			
			feetCastResutList.clear();
			Phys.space.convexMultiCast(feetShape, 1/60, false, feetShape.filter, feetCastResutList);
			
			var sucked:Bool = false;
			feetCastResutList.foreach(function(result:ConvexResult) {
				if (!sucked && result != null && !result.shape.sensorEnabled && Math.abs(result.normal.angle * FlxAngle.TO_DEG + 90)  <= groundable.groundedAngleLimit) {
					body.integrate(result.toi);
					entity.groundable.add(result.shape.body.userData.entity);
					sucked = true;
				}
			});
			
			body.velocity.set(oldVel);
			
			
			if (!sucked) body.position.y++;
		}
		
		// Moving Left/Right
		if (hasControl) {//TODO tidy up control, probably differentiate between hascontrol and input enabled
			if (actionLeft != actionRight) {
				targetMoveVel = actionLeft ? -runSpeed : runSpeed;
				move();
			} else {
				FlxG.watch.addQuick("mv", currentMoveVel);
				if (Math.abs(currentMoveVel) > 0) stop();
				if (!groundable.isGrounded) physics.body.velocity.x = 0;
			}
		}
		
		// Ground friction
		var groundable:GroundableComponent = entity.groundable;
		FlxG.watch.addQuick("grounded", groundable.isGrounded);
		if (groundable.isGrounded && !isMoving) {
			feetShape.material.dynamicFriction = 1000;
			feetShape.material.staticFriction = 1000;
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
		
		if (hasControl && actionJump) {
			if (canJump) {
				currentJumps++;
				physics.body.velocity.y = jumpSpeed;
				onCharacterJump.dispatch(this.entity);
			}
		}
		
		dropThrough = false;	
		if (hasControl && FlxG.keys.anyPressed([FlxKey.S, FlxKey.DOWN])) {
			dropThrough = true;
		}
		
		resetActions();
	}
	
	// TODO i removed stopAccel at some point to have a hard stop but it would be good to make the customisable
	public function stop() {
		targetMoveVel = 0;
		// TODO probably issues with this method when running into a wall as walls don't zero it
		currentMoveVel = 0;
		
		if (Math.abs(currentMoveVel) < minMoveVel) {
			currentMoveVel = 0;
			isSliding = false;
		}
		
		physics.body.velocity.x = currentMoveVel;
		anchor.kinematicVel.x = currentMoveVel;
	}
	
	public function jump() {
		if (hasControl) actionJump = true;
	}
	
	private function set_hasControl(val:Bool):Bool {
		if (val == hasControl) return val;
		
		this.hasControl = val;
		resetActions();
		
		if (hasControl) {
			anchorJoint.space = anchor.space = entity.physics.space;
		} else {
			anchorJoint.space = anchor.space = null;
		}
		
		return val;
	}
}