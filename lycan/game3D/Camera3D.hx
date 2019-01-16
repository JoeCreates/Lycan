package lycan.game3D;

import lycan.game3D.components.Position3D;
import lycan.game3D.Point3D;

class Camera3D {
	public var pos:Point3D;
	public var angle:Point3D;
	public var depth:Float;
	
	public function new(x:Float = 0, y:Float = 0, z:Float = 0, ax:Float = 0, ay:Float = 0, az:Float = 0) {
		pos = Point3D.get(x, y, z);
		angle = Point3D.get(ax, ay, az);
	}
}