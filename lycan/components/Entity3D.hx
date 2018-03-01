package lycan.components;

import flixel.FlxG;
import flixel.system.frontEnds.SignalFrontEnd;
import lycan.util.Point3D;

interface Entity3D extends Entity {
	public var position3D:Position3D;
}

@:tink
class Position3D extends Component<Entity3D> {
	@:forward public var point:Point3D;
	
	public function new(entity:Entity3D) {
		super(entity);
		point = Point3D.get();
	}
}