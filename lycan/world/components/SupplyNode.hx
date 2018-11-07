package lycan.world.components;

import entities.Player;
import lycan.components.Entity;
import lycan.components.Component;
import lycan.components.Attachable;

interface SupplyNode extends Entity {
	public var supplyNode:SupplyNodeComponent;
}

class SupplyNodeComponent extends Component<SupplyNode> {
	private var dirty:Bool;
	
	public function new(entity:SupplyNode) {
		super(entity);
	}
}