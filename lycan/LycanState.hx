package lycan;

import flixel.FlxSubState;


class LycanState extends FlxSubState implements LateUpdater {
	
	public var lateUpdates:List<LateUpdatable>;
	
	public function new() {
		super();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		lateUpdate(dt);
	}
	
	public function lateUpdate(dt:Float):Void {
		var update:Float->Void;
		while ((update = lateUpdates.pop()) != null) {
			update(dt);
		}
	}
	
	public function updateLater(update:Float->Void):Void {
		lateUpdates.add(update);
	}
	
}