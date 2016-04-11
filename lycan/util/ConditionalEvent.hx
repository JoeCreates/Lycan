package lycan.util;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;

class ConditionalEvent extends FlxBasic {
	public var condition:Void->Bool;
	public var callback:ConditionalEvent->Void;
	public var state:FlxState;
	
	/** Begin waiting for a condition to be fulfilled before calling a callback */
	public static function wait(condition:Void->Bool, callback:ConditionalEvent->Void):ConditionalEvent {
		var cond:ConditionalEvent = new ConditionalEvent(condition, callback);
		cond.state.add(cond);
		return cond;
	}
	
	private function new(condition:Void->Bool, callback:ConditionalEvent->Void) {
		super();
		this.condition = condition;
		this.callback = callback;
		this.state = FlxG.state.subState;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		if (active && condition()) {
			finish();
		}
	}
	
	public function finish():Void {
		active = false;
		state.remove(this);
		callback(this);
	}
	
	public function cancel():Void {
		active = false;
		state.remove(this);
		destroy();
	}
	
	override public function destroy():Void {
		super.destroy();
		state = null;
		condition = null;
		callback = null;
	}
}