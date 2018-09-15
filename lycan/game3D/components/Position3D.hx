package lycan.game3D.components;

import lycan.game3D.Point3D;
import lycan.components.Entity;
import lycan.components.Component;

interface Position3D extends Entity {
	public var pos3D:Position3DComponent;
}

@:tink
class Position3DComponent extends Component<Position3D> {
	@:forward public var point:Point3D;
	
	public function new(entity:Position3D) {
		super(entity);
		point = Point3D.get();
	}
}