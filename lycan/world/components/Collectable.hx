package lycan.world.components;

import entities.Player;
import lycan.components.Entity;
import lycan.components.Component;
import lycan.components.Attachable;

interface Collectable extends Entity {
	public var collectable:CollectableComponent;
	
	@:relaxed public var x(get, set):Float;
	@:relaxed public var y(get, set):Float;
	@:relaxed public var width(get, set):Float;
	@:relaxed public var height(get, set):Float;
}

class CollectableComponent extends Component<Collectable> {
	/** Whether this object has been collected */
	public var collected(default, null):Bool;
	/** Function to call when this collectable is collected */
	public var onCollect:Dynamic->Void;
	/** The thing which collected this collectable */
	public var collector:Dynamic;
	
	public function init():Void {
		collected = false;
		collector = null;
	}
	
	public function collect(collector:Dynamic):Bool {
		if (collected) return false;
		
		this.collector = collector;
		onCollect(collector);
		collected = true;
		return true;
	}
}