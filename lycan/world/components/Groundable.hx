package lycan.world.components;

import flixel.FlxObject;
import lycan.components.Component;
import lycan.components.Entity;
import flixel.util.FlxSignal;

interface Groundable extends Entity {
	public var groundable:GroundableComponent;
}

class GroundableComponent extends Component<Groundable> {
	public static var clearGroundsSignal:FlxSignal = new FlxSignal();
	
	private var currentGrounds:Map<FlxObject, Bool>;
	private var currentGroundCount:Int;
	
	public var wasGrounded:Bool;
	public var isGrounded(get, never):Bool;
	/** Whether to force grounded checks to return true */
	public var forceGrounded:Bool;
	
	public function new(entity:Groundable) {
		super(entity);
		currentGrounds = new Map<FlxObject, Bool>();
		currentGroundCount = 0;
		wasGrounded = false;
		forceGrounded = false;
	}
	
	@:append("update")
	public function update(dt:Float):Void {
		wasGrounded = isGrounded;
	}
	
	public function add(object:FlxObject):Void {
		if (!currentGrounds.exists(object)) {
			currentGrounds.set(object, true);
			currentGroundCount++;
			clearGroundsSignal.addOnce(()->{
				remove(object);
			});
		}
	}
	
	public function remove(object:FlxObject):Void {
		if (currentGrounds.exists(object)) {
			currentGrounds.remove(object);
			currentGroundCount--;
		}
	}
	
	private function get_isGrounded():Bool {
		return forceGrounded || currentGroundCount > 0;
	}
}