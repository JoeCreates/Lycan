package lycan.phys;

import box2D.collision.shapes.B2MassData;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Body;

abstract B2WorldExt(B2World) to B2World from B2World {
	
	
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