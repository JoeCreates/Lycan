package lycan.util.timeline;

import lycan.util.timeline.Easing;

class Tween extends TimelineItem {
	public var ease:Float->Float;
	
	public function new(target:Dynamic, startTime:Float, duration:Float, ease:Float->Float) {		
		super(null, target, startTime, duration);
		this.ease = ease;
	}
	
	override public function onEnterLeft(count:Int):Void {
		
	}
	
	override public function onExitLeft(count:Int):Void {
		
	}
	
	override public function onEnterRight(count:Int):Void {
		
	}
	
	override public function onExitRight(count:Int):Void {
		
	}
	
	override public function onUpdate(time:Float):Void {
		
	}
}