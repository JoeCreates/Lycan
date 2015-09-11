package lycan.util.timeline;

class Cue extends TimelineItem {
	public var fn(default, default):Void->Void;
	
	public function new(target:Dynamic, fn:Void->Void, atTime:Float = 0) {
		super(null, target, atTime, 0);
		this.fn = fn;
	}
	
	override private function get_updateAtLoopStart():Bool {
		return true;
	}
	
	override public function onStart(reverse:Bool):Void {
		trace("START");
		if (fn != null) {
			fn();
		}
	}
	
	override public function onLoopStart():Void {
		trace("LOOPSTART");
		if (fn != null) {
			fn();
		}
	}
	
	override public function update(relativeTime:Float):Void {
		//trace("UPDATE");
		//if (fn != null) {
		//	fn();
		//}
	}
	
	override public function onComplete(reverse:Bool):Void {
		trace("COMPLETE");
		if (fn != null) {
			fn();
		}
	}
}