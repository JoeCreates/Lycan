package lycan.world.components;

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


interface CharacterController extends Entity {
	public var characterController:CharacterControllerComponent;
	public var physics:PhysicsComponent;
	public var groundable:GroundableComponent;
}

@:tink
class CharacterControllerComponent extends Component<CharacterController> {
	@:forward var _object:FlxObject;
	var physics(get, never):PhysicsComponent;
	function get_physics() return entity.physics;
	
	var jumpSpeed:Float = -900;
	var runImpulse:Float = 1000;
	var runSpeed:Float = 600;
	var maxJumps:Int = 2;
	var maxJumpVelY:Float = 200;
	var airDrag:Float = 5000;
	
	public var dropThrough:Bool = false; 
	
	/** Indicates how in control the character is. Applies high drag while in air. */
	var hasControl:Bool;
	var currentJumps:Int;
	var canJump:Bool;
	
	//var movingPlatforms:Array<MovingPlatform>;
	//var currentMovingPlatform:MovingPlatform;
	
	var bodyShape:Shape;
	var feetShape:Shape;
	
	public function new(entity:CharacterController) {
		super(entity);
		
		_object = cast entity;
	}
	
	public function init() {
		physics.init(BodyType.DYNAMIC, false);
		physics.body.position.setxy(x, y);
		physics.body.allowRotation = false;
		feetShape = new Circle(width / 2, Vec2.weak(0, (height - width) / 2));
		bodyShape = new Polygon(Polygon.rect(-width / 2, -height / 2, width, height - width / 2));
		physics.body.shapes.add(feetShape);
		physics.body.shapes.add(bodyShape);
		physics.setBodyMaterial();
		
		physics.body.isBullet = true;
		
		hasControl = true;
		currentJumps = 0;
		
		physics.body.cbTypes.add(PlatformerPhysics.characterType);
		physics.body.cbTypes.add(PlatformerPhysics.groundableType);
	}
	
	//TODO destroy
	
	@:prepend("update")
	public function update(dt:Float):Void {
		var body:Body = physics.body;
		
		// Ground sucking
		// TODO Doesnt make grounded... is this a bad method? Fires leave listeners that shouldnt...
		var oldVel:Vec2 = body.velocity.copy(true);
		body.velocity.setxy(0, 10 * 60);//TODO customisable
		body.position.y--;
		var result:ConvexResult = Phys.space.convexCast(feetShape, 1/60, false);
		body.velocity.set(oldVel);
		if (result != null && result.toi > 1/600) {
			body.position.y += 600 * result.toi;
		} else {
			body.position.y++;
		}
		
		var running:Bool = false;
		if (physics.body.velocity.x > -runSpeed && FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT])) {
			physics.body.applyImpulse(Vec2.weak(-runImpulse, 0));
			running = true;
		} else if (physics.body.velocity.x < runSpeed && FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT])) {
			physics.body.applyImpulse(Vec2.weak(runImpulse, 0));
			running = true;//TODO rename to moving
		}
		if (FlxG.keys.anyPressed([A, LEFT, RIGHT, D])) running = true;
		
		var groundable:GroundableComponent = entity.groundable;
		FlxG.watch.addQuick("grounded", groundable.isGrounded);
		if (groundable.isGrounded && !running) {
			feetShape.material.dynamicFriction = 100;
			feetShape.material.staticFriction = 100;
		} else {
			feetShape.material.dynamicFriction = 0;
			feetShape.material.staticFriction = 0;
		}
		
		if (groundable.isGrounded) {
			currentJumps = 0;
			canJump = true;
		} else {
			if (hasControl && !running) {
				var vx:Float = body.velocity.x;
				body.velocity.x -= FlxMath.signOf(vx) * Math.min(dt * airDrag, Math.abs(vx));
			}
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
		if (FlxG.keys.anyJustPressed([FlxKey.S, FlxKey.DOWN])) {
			dropThrough = true;
			//body.cbTypes.
		}
		
		//physics.body.getContactList
		// TODO double jumps + not hanging on walls
	}
	
	public function run() {
		
	}
	
	public function jump() {
		
	}
}