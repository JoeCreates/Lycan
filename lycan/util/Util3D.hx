package lycan.util;

import lycan.util.Point3D;
import openfl.geom.Vector3D;

class Util3D {
	
	public static function getNormal(v1:Point3D, v2:Point3D, v3:Point3D, ?out:Point3D):Point3D {
		if (out == null) out = Point3D.get();
		
		out = Point3D.get().copyFrom(v1).subtract(v2);
		var b:Point3D = Point3D.get().copyFrom(v1).subtract(v3);
		
		out = out.crossProduct(b);
		
		a.put();
		b.put();
		
		return out;
		
	}
}