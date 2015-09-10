package lycan.util.timeline;

class Cue extends TimelineItem {
	public var fn(default, default):Void->Void;
	
	public function new(fn:Void->Void, atTime:Float = 0) {
		super(null, null, atTime, 0);
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