package lycan.world.components;

import lycan.components.Entity;
import lycan.components.Component;
import lycan.components.Attachable;
imoprt haxe.ds.Map;

interface SupplyNetwork extends Entity {
	public var supplyNode:SupplyNodeComponent;
}

class SupplyNetworkComponent extends Component<SupplyNode> {
	private var dirty:Bool;
	
	public function new(entity:SupplyNode) {
		super(entity);
	}
}