package lycan.world.components;

import lycan.components.Component;
import lycan.components.Entity;

// TODO generalise to multiple states
interface Switchable extends Entity {
	public var switcher:SwitchComponent;
}

class SwitchComponent extends Component<Switchable> {
	
	public var on(default, set):Bool;
	
	public var onCallback:Switchable->Void;
	public var offCallback:Switchable->Void;
	
	public function new(entity:Switchable) {
		super(entity);
	}
	
	public function toggle():Void {
		on = !on;
	}
	
	private function set_on(on:Bool):Bool {
		if (this.on == on) return on;
		
		this.on = on;
		if (on) {
			if (onCallback != null) onCallback(entity);
		} else {
			if (offCallback != null) offCallback(entity);
		}
		
		return on;
	}
}