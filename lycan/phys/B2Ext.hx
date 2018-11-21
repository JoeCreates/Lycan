package lycan.phys;

import box2D.dynamics.B2FilterData;
import box2D.collision.shapes.B2MassData;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.contacts.B2Contact;

// Class for static extension ("using")
class B2Ext {
	public static function getContactFixtureByCategory(contact:B2Contact, category:Int):B2Fixture {
		for (f in [contact.m_fixtureA, contact.m_fixtureB]) {
			if (fixtureHasCategoryf, category)) return f;
		}
		return null;
	}
	
	public static function fixtureHasCategory(fixture:B2Fixture, category:Int):Bool {
		return fixture.m_filter.categoryBits & category > 0;
	}
}

abstract B2WorldExt(B2World) to B2World from B2World {
	// TODO Convex cast
	
}

abstract B2BodyExt(B2Body) to B2Body from B2Body {
	static var massData:B2MassData = new B2MassData();

	public var mass(get, set):Float;
	
	inline function get_mass():Float return this.getMass();
	inline function set_mass(mass:Float):Float {
		this.getMassData(massData);
		massData.mass = mass;
		this.setMassData(massData);
	}
	
}