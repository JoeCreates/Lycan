package lycan.util;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

class ConditionalEventManager extends FlxTypedGroup<ConditionalEvent> {
	/** Begin waiting for a condition to be fulfilled before calling a callback */
	public function wait(condition:Void->Bool, callback:ConditionalEvent->Void):ConditionalEvent {
		var cond:ConditionalEvent = new ConditionalEvent(condition, callback);
		add(cond);
		return cond;
	}
	
	override public function update(dt:Float):Void {
		for (event in members) {
			if (event != null && event.queueRemoval) {
				remove(event);
				event.destroy();
			}
		}
		super.update(dt);
	}
	
	public function cancelAll():Void {
		forEachExists((e)->{e.cancel(); });
	}
}

class ConditionalEvent extends FlxBasic {
	public var queueRemoval(default, null):Bool;
	public var condition:Void->Bool;
	public var callback:ConditionalEvent->Void;
	
	public function new(condition:Void->Bool, callback:ConditionalEvent->Void) {
		super();
		this.queueRemoval = false;
		this.condition = condition;
		this.callback = callback;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		if (condition()) {
			finish();
		}
	}
	
	public function finish():Void {
		active = false;
		queueRemoval = true;
		callback(this);
	}
	
	public function cancel():Void {
		active = false;
		queueRemoval = true;
	}
	
	override public function destroy():Void {
		super.destroy();
		condition = null;
		callback = null;
	}
}