package lycan.phys;

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

// TODO could be PhysicsPresets?
class PlatformerPhysics {
	
	public static var collisionType:CbType = new CbType();
	public static var groundableType:CbType = new CbType();
	public static var onewayType:CbType = new CbType();
	
	public static function setupPlatformerPhysics():Void {
		trace("Setting up platforming physics");
		// Landing on ground
		Phys.space.listeners.add(
			new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, groundableType, CbType.ANY_BODY,
				function(ic:InteractionCallback):Void {
					var body:Body = ic.int1.castBody;
					//TODO ask msghero
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
		
		// One way platforms
		// TODO should use accept/ignore_once?
		Phys.space.listeners.push(
			new PreListener(InteractionType.COLLISION, CbType.ANY_BODY, onewayType,
			function(ic:PreCallback):PreFlag {
					var groundable:Groundable = ic.int1.userData.sprite;
					var arbiter:CollisionArbiter = cast ic.arbiter;
					var angle:Float = FlxAngle.TO_DEG * arbiter.normal.angle;
					if (angle >= 45 && angle <= 135 ) {
						return PreFlag.ACCEPT;
					}
					return PreFlag.IGNORE;
				}
			)
		);
		
	}
}