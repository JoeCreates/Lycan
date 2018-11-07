package lycan.world.components;

import entities.Player;
import lycan.components.Entity;
import lycan.components.Component;
import lycan.components.Attachable;

interface SupplySource extends Entity {
	public var supplySource:SupplySourceComponent;
}

class SupplySourceComponent extends Component<SupplySource> {
	public var supply:Bool;
	
	public function new(entity:SupplySource) {
	}
	
	public function init():Void {
	}
}