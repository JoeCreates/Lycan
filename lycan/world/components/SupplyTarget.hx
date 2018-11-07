package lycan.world.components;

import entities.Player;
import lycan.components.Entity;
import lycan.components.Component;
import lycan.components.Attachable;

interface SupplyTarget extends Entity {
	public var supplyTarget:SupplyTargetComponent;
}

class SupplyTargetComponent extends Component<SupplyTarget> {
	public var isSupplied:Bool;
	
	public function new(entity:SupplyTarget) {
		super(entity);
	}
	
	public function init():Void {
	}
}