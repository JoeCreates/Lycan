package lycan.util.timeline;

class Cue extends TimelineItem {
	public var fn(default, default):Void->Void;
	
	public function new(target:Dynamic, fn:Void->Void, atTime:Float = 0, removeOnCompletion:Bool = false) {
		super(null, target, atTime, 0);
		this.fn = fn;
		this.removeOnCompletion = removeOnCompletion;
	}
	
	override public function onEnterLeft(count:Int):Void {
		trace("ENTER LEFT x" + count);
		if (fn != null) {
			fn();
		}
	}
	
	override public function onExitLeft(count:Int):Void {
		trace("EXIT LEFT x" + count);
		if (fn != null) {
			fn();
		}
	}
	
	override public function onEnterRight(count:Int):Void {
		trace("ENTER RIGHT x" + count);
		if (fn != null) {
			fn();
		}
	}
	
	override public function onExitRight(count:Int):Void {
		trace("EXIT RIGHT x" + count);
		if (fn != null) {
			fn();
		}
	}
	
	override public function onUpdate(time:Float):Void {
		
	}
}