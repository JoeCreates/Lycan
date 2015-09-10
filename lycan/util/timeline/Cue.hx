package lycan.util.timeline;

class Cue extends TimelineItem {
	public var fn(default, default):Void->Void;
	
	public function new(target:Dynamic, fn:Void->Void, atTime:Float = 0) {
		super(null, target, atTime, 0);
		this.fn = fn;
	}
	
	override public function loopStart():Void {
		if (fn != null) {
			fn();
		}
	}
	
	override private function get_updateAtLoopStart():Bool {
		return true;
	}
}