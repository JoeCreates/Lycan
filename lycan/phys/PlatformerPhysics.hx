package lycan.phys;

import flixel.FlxG;
import nape.callbacks.PreCallback;
import nape.callbacks.PreListener;
import nape.callbacks.InteractionCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.CbType;
import nape.callbacks.InteractionType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import lycan.world.components.Groundable;
import nape.phys.Body;
import nape.dynamics.CollisionArbiter;
import flixel.math.FlxAngle;
import lycan.world.components.CharacterController;
import nape.space.Space;


// TODO could be PhysicsPresets?
class PlatformerPhysics {
	
	public static var collisionType:CbType = new CbType();
	public static var groundableType:CbType = new CbType();
	public static var characterType:CbType = new CbType();
	public static var onewayType:CbType = new CbType();
	public static var pushableType:CbType = new CbType();
	public static var movingPlatformType:CbType = new CbType();
	
	public static function setupPlatformerPhysics(?space:Space):Void {
		space = space == null ? Phys.space : space;
		
		// Landing on ground
		space.listeners.add(
			new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, groundableType, CbType.ANY_BODY,
				function(ic:InteractionCallback):Void {
					var body:Body = ic.int1.castBody;
					//TODO why did I do this? waking it up?
					body.position.x += 1;
					body.position.x -= 1;
					var groundable:Groundable = cast ic.int1.userData.entity;
					for (arbiter in ic.arbiters) {
						if (!arbiter.isCollisionArbiter()) continue;
						var groundableFirst:Bool = arbiter.body1 == body;
						var ca:CollisionArbiter = cast arbiter;
						var angle:Float = FlxAngle.TO_DEG * ca.normal.angle - (groundableFirst ? 90 : -90);
						// If we just left the ground
						if (arbiter.collisionArbiter.totalImpulse().length == 0) {
							groundable.groundable.remove(cast ic.int2.userData.entity);
						} else if (angle >= -groundable.groundable.groundedAngleLimit && angle <= groundable.groundable.groundedAngleLimit) {
							groundable.groundable.add(cast ic.int2.userData.entity);
						}
					}
				}
			)
		);
		
		// Character controller drop-through one way
		space.listeners.add(
			new PreListener(InteractionType.COLLISION, characterType, onewayType,
				function(ic:PreCallback):PreFlag {
					var body:Body = ic.int1.castBody;
					var p:CharacterController = cast body.userData.entity;
					if (p.characterController.dropThrough) {
						return PreFlag.IGNORE;
					} else {
						return null;
					}
				}, 1
			)
		);
		
		// Avoid vertical friction on grounds
		// TODO could we merge this with groun checks?
		space.listeners.add(
			new PreListener(InteractionType.COLLISION, groundableType, CbType.ANY_BODY,
				function(ic:PreCallback):PreFlag {
					var body:Body = ic.int1.castBody;
					var groundable:Groundable = cast body.userData.entity;
					var arbiter = ic.arbiter;
					
					if (!arbiter.isCollisionArbiter()) return null;
					var ca:CollisionArbiter = cast arbiter;
					var angle:Float = FlxAngle.TO_DEG * ca.normal.angle - (arbiter.body1 == body ? 90 : -90);
					
					if (!(angle >= -groundable.groundable.groundedAngleLimit && angle <= groundable.groundable.groundedAngleLimit)) {
						ca.dynamicFriction = 0;
						ca.staticFriction = 0;
					}
					
					// We don't need to change the acceptance
					return PreFlag.ACCEPT_ONCE;//TODO fights onewyas?
				}
			)
		);
		
		// One way platforms
		// TODO should use accept/ignore_once?
		// TODO don't hardcode the angles
		space.listeners.push(
			new PreListener(InteractionType.COLLISION, CbType.ANY_BODY, onewayType,
				function(ic:PreCallback):PreFlag {
					var groundable:Groundable = ic.int1.userData.sprite;
					var arbiter:CollisionArbiter = cast ic.arbiter;
					var angle:Float = FlxAngle.TO_DEG * arbiter.normal.angle;
					if (angle >= 45 && angle <= 135 ) {
						return null;
					}
					return PreFlag.IGNORE;
				}, 2
			)
		);
		
	}
}