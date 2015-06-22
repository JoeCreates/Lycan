package lycan;

import flixel.FlxSubState;
import flixel.FlxBasic;

class LycanState extends FlxSubState implements LateUpdatable {
	// Double check lateupdate is being called
	private var updatesWithoutLateUpdates:Int;
	
	override public function update(dt:Float):Void {
		super.update(dt);
		updatesWithoutLateUpdates++;
		if (updatesWithoutLateUpdates > 1) throw("lateUpdate has not been called since last update");
	}
	
	public function lateUpdate(dt:Float) {
		updatesWithoutLateUpdates = 0;
		forEach(function(o:FlxBasic) {
			if (Std.is(o, LateUpdatable)) {
				var u:LateUpdatable = cast o;
				u.lateUpdate(dt);
			}
		}, true);
	}
}