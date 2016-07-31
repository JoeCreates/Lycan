package lycan.util;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;

class ConditionalEvent extends FlxBasic {
	public var condition:Void->Bool;
	public var callback:ConditionalEvent->Void;
	public var state:FlxState;
	
	/** Begin waiting for a condition to be fulfilled before calling a callback */
	public static function wait(state:FlxSubState, condition:Void->Bool, callback:ConditionalEvent->Void):ConditionalEvent {
		var cond:ConditionalEvent = new ConditionalEvent(condition, callback, state);
		cond.state.add(cond);
		return cond;
	}
	
	private function new(condition:Void->Bool, callback:ConditionalEvent->Void, state:FlxSubState) {
		super();
		this.condition = condition;
		this.callback = callback;
		this.state = state;
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