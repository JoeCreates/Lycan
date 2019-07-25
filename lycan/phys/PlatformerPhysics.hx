package lycan.phys;

import nape.geom.Geom;
import nape.dynamics.Contact;
import nape.shape.Polygon;
import nape.dynamics.InteractionFilter;
import nape.shape.Shape;
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
import nape.dynamics.InteractionGroup;
import nape.geom.Vec2;
import nape.geom.Vec3;
import nape.phys.BodyType;

// TODO could be PhysicsPresets?
class PlatformerPhysics {
	
	public static var collisionType:CbType = new CbType();
	public static var groundableType:CbType = new CbType();
	public static var characterType:CbType = new CbType();
	public static var onewayType:CbType = new CbType();
	public static var pushableType:CbType = new CbType();
	public static var movingPlatformType:CbType = new CbType();
	
	public static var worldFilterGroup:Int = 2;
	public static var objectFilterGroup:Int = 4;
	public static var overlappingObjectFilterGroup:Int = 8;
	public static var overlappingWorldFilterGroup:Int = 16;
	
	public static var worldFilter = new InteractionFilter(worldFilterGroup, 1 | objectFilterGroup | worldFilterGroup | overlappingObjectFilterGroup);
	public static var overlappingWorldFilter = new InteractionFilter(overlappingWorldFilterGroup, 1 | objectFilterGroup | worldFilterGroup | overlappingObjectFilterGroup);
	public static var objectFilter = new InteractionFilter(objectFilterGroup, 1 | worldFilterGroup | objectFilterGroup | overlappingObjectFilterGroup | overlappingWorldFilterGroup);
	public static var overlappingObjectFilter = new InteractionFilter(overlappingObjectFilterGroup, 1 | worldFilterGroup | objectFilterGroup | overlappingWorldFilterGroup);
	
	public static var overlappingObjectGroup:InteractionGroup = new InteractionGroup(true);
	
	private static var isSetup:Bool = false;
	
	public static function setupPlatformerPhysics(?space:Space):Void {
		if (space == Phys.space) {
			if (isSetup) {
				return;
			} else {
				isSetup = true;
			}
		}
		
		space = space == null ? Phys.space : space;
		
		// Landing on ground
		// space.listeners.add(
		// 	new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, groundableType, CbType.ANY_SHAPE,
		// 		function(ic:InteractionCallback):Void {
		// 			var body:Body = ic.int1.castBody;
		// 			//TODO why did I do this? waking it up?
		// 			body.position.x += 1;
		// 			body.position.x -= 1;
		// 			var groundable:Groundable = cast ic.int1.userData.entity;
		// 			for (arbiter in ic.arbiters) {
		// 				if (!arbiter.isCollisionArbiter()) continue;
		// 				var groundableFirst:Bool = arbiter.body1 == body;
		// 				var ca:CollisionArbiter = cast arbiter;
		// 				var angle:Float = FlxAngle.TO_DEG * ca.normal.angle - (groundableFirst ? 90 : -90);
		// 				// If we just left the ground
		// 				if (arbiter.collisionArbiter.totalImpulse().length == 0) {
		// 					groundable.groundable.remove(cast ic.int2.userData.entity);
		// 				} else if (angle >= -groundable.groundable.groundedAngleLimit && angle <= groundable.groundable.groundedAngleLimit) {
		// 					groundable.groundable.add(cast ic.int2.userData.entity);
		// 				}
		// 			}
		// 		}
		// 	)
		// );
		
		var threshold:Float = 2;
		// Attempt to work around ghost edges issue
		// TODO it's a work in progress
		space.listeners.add(
			new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, CbType.ANY_BODY, Phys.tilemapShapeType,
				function(ic:InteractionCallback) {
					var b1:Body = ic.int1.isShape() ? ic.int1.castShape.body : ic.int1.castBody;
					var b2:Body = ic.int2.isShape() ? ic.int2.castShape.body : ic.int2.castBody;
					
					if (b1.shapes.at(0).cbTypes.has(Phys.tilemapShapeType) && b1.type != BodyType.DYNAMIC) {
						var tb = b1;
						b1 = b2;
						b2 = tb;
					}
					
					if (b1.type != BodyType.DYNAMIC) {
						return;
					}
					
					for (a in ic.arbiters) {
						if (a.isCollisionArbiter()) {
							var ca:CollisionArbiter = cast a.collisionArbiter;
							var s1 = ca.shape1;
							var s2 = ca.shape2;
							if (s1.body != b1) {
								var ts = s1;
								s1 = s2;
								s2 = ts;
							}
							if (Math.abs(ca.normal.y) > 0) {
								var d:Float;
								if (s1.bounds.x > s2.bounds.x) {
									d = s2.bounds.x + s2.bounds.width - s1.bounds.x;
								} else {
									d = -(s1.bounds.x + s1.bounds.width - s2.bounds.x);
								}
								if (Math.abs(d) > threshold) break;
								b1.position.x += d;
								var impulse:Vec3 = ca.contacts.at(0).normalImpulse();
								// trace("impulse: " + impulse);
								// trace("totalImpulse: " + impulse);
								b1.applyImpulse(Vec2.weak(impulse.x, impulse.y));
								break;
							}
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
					if (!Std.is(body.userData.entity, CharacterController)) return null;
					var p:CharacterController = cast body.userData.entity;
					if (p.characterController.dropThrough) {
						return PreFlag.IGNORE;
					} else {
						return null;
					}
				}, 1
			)
		);
		
		// Avoid vertical friction on grounds/characters
		// TODO could we merge this with groun checks?
		space.listeners.add(
			new PreListener(InteractionType.COLLISION, groundableType, CbType.ANY_SHAPE,
				function(ic:PreCallback):PreFlag {
					var body:Body = ic.int1.castBody;
					var groundable:Groundable = cast body.userData.entity;
					var groundable2:Groundable = null;
					
					if (ic.int2.castShape.body.cbTypes.has(groundableType)) {
						groundable2 = cast ic.int2.castShape.body.userData.entity;
					}
					
					var arbiter = ic.arbiter;
					
					if (!arbiter.isCollisionArbiter()) return null;
					var ca:CollisionArbiter = cast arbiter;
					var angle:Float = FlxAngle.TO_DEG * ca.normal.angle - (arbiter.body1 == body ? 90 : -90);
					var inverseAngle:Float = FlxAngle.TO_DEG * ca.normal.angle - (arbiter.body1 != body ? 90 : -90);
					
					var isGrounded1:Bool = false;// Whether within grounable angle limit for first groundable
					var isGrounded2:Bool = false;// ...and also for second grounable if there is one
					
					if (angle >= -groundable.groundable.groundedAngleLimit && angle <= groundable.groundable.groundedAngleLimit) {
						isGrounded1 = true;
					}
					if (groundable2 != null && inverseAngle >= -groundable2.groundable.groundedAngleLimit && inverseAngle <= groundable2.groundable.groundedAngleLimit) {
						isGrounded2 = true;
					}
					
					if (!(isGrounded1 || isGrounded2)) {
						ca.dynamicFriction = 0;
						ca.staticFriction = 0;
					}
					
					// We don't need to change the acceptance
					return null;//TODO fights onewyas?
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
					if (arbiter.shape1.cbTypes.has(onewayType) || arbiter.shape1.body.cbTypes.has(onewayType)) {
						angle += 180;
						angle %= 360;	
					}
					if (angle >= 45 && angle <= 135 ) {
						return null;
					}
					return PreFlag.IGNORE;
				}, 2
			)
		);
		
	}
}