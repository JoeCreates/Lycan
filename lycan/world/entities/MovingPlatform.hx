package lycan.world.entities;
import flixel.FlxObject;

// TODO generalise to multiple states
interface Switchable {
	
}

class MovingPlatform extends Component {
	
	public var on(default, set):Bool;
	
	public var onCallback:Switch->Void;
	public var offCallback:Switch->Void;
	
	public function new(entity:FlxObject) {
		super(entity);
	}
	
	public function toggle():Void {
		on = !on;
	}
	
	private function set_on(on:Bool):Bool {
		if (this.on == on) return on;
		
		this.on = on;
		if (on) {
			onCallback(this);
		} else {
			offCallback(this);
		}
		
		return on;
	}
}