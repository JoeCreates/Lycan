package lycan.util.timeline;

class Tween extends TimelineItem {
	static public var 
	
	public function new(target:Dynamic, startAt:Float, duration:Float, ease:Float->Float) {		
		super(null, target, startAt, duration);
		this.fn = fn;
		this.removeOnCompletion = removeOnCompletion;
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