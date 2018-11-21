package lycan.phys;

import box2D.collision.B2WorldManifold;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.contacts.B2Contact;
import box2D.collision.B2Manifold;
import box2D.dynamics.B2ContactListener;
import lycan.phys.B2Ext;
import lycan.phys.PlatformerFilterPresets;
import lycan.world.components.Groundable;

using lycan.phys.B2Ext;

class PlatformerContactListener extends B2ContactListener {
	/**	This category indicates the entity in userData should be checked when presolving */
	public var entityPresolveCategory:Int = 1 << 15;
	public var groundableCategories:Int = PlatformerFilterPresets.worldObject.categoryBits;
	public var groundCategories:Int = PlatformerFilterPresets.world.categoryBits;
	/** World objects collide with the world but not with each other */
	public var worldObjectGroup:Int = PlatformerFilterPresets.world.groupIndex;
	
	public var maxGroundAngle:Float = 60;
	
	static var worldManifold:B2WorldManifold = new B2WorldManifold();
	
	override function preSolve(contact:B2Contact, oldManifold:B2Manifold) {
		if (!contact.isTouching()) return;
		
		var fa:B2Fixture = contact.m_fixtureA;
		var fb:B2Fixture = contact.m_fixtureB;
		
		// Groundable handling
		var ground:B2Fixture;
		var groundable:B2Fixture;
		// If both grounds and groundables, use y positions to determnie which is ground
		if (fa.fixtureHasCategory(groundCategories) && fb.fixtureHasCategory(groundCategories)
			&& fa.fixtureHasCategory(groundableCategories) && fb.fixtureHasCategory(groundableCategories)) {
				// TODO this wont work for complex bodies, we'd need to check the shapes' world positions
				if (fa.m_body.getPosition().y > fb.m_body.getPosition().y) {
					ground = fb;
					groundable = fa;
				} else {
					ground = fa;
					groundable = fb;
				}
		} 
		else if (fa.fixtureHasCategory(groundCategories) && fb.fixtureHasCategory(groundableCategories)) {
			ground = fa;
			groundable = fb;
		}
		else if (fa.fixtureHasCategory(groundableCategories) && fb.fixtureHasCategory(groundCategories)) {
			ground = fb;
			groundable = fa;
		}
		
		if (ground != null && groundable != null) {
			contact.getWorldManifold(worldManifold);
			var wm = worldManifold;
			
			var normal:FlxVector = FlxVector.get(wm.m_normal.x, wm.m_normal.y);
			var isAGround:Bool = contact.m_fixtureA == ground;
			var a:Float = normal.angleBetween(FlxPoint.weak(0, 0)) - (isAGround ? 180 : 0);
			normal.put();
			
			// If there is a valid grounding
			if (Math.abs(a) <= maxGroundAngle) {
				var gc:GroundableComponent = cast groundable.m_userData;
				var groundEntity:Entity = cast ground.m_userData.entity; 
				if (groundEntity != null) gc.add(groundEntity);
				
				// Disable friction on this contact
				contact.set
			}
		}
	}
}