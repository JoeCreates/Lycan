package lycan.phys;

import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.contacts.B2Contact;
import box2D.collision.B2Manifold;
import box2D.dynamics.B2ContactListener;
import lycan.phys.B2Ext;

using lycan.phys.B2Ext;

class PlatformerFilterPresets {
	public static var worldObject:B2FilterData;
	public static var solidWorldObject:B2FilterData;
	public static var world:B2FilterData;
		
	public static function init():Void {
		worldObject = new B2FilterData();
		worldObject.categoryBits = 2;
		worldObject.groupIndex = -1;
		
		solidWorldObject = new B2FilterData();
		solidWorldObject.categoryBits = 2;
		
		world = new B2FilterData();
		worl.categoryBits = 1;
	}
}