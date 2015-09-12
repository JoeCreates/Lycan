package lycan.util.timeline;

class Cue extends TimelineItem {
	private var enterLeft:Void->Void;
	private var exitRight:Void->Void;
	private var enterRight:Void->Void;
	private var exitLeft:Void->Void;
	
	public function new(target:Dynamic, startTime:Float, ?enterLeft:Void->Void, ?exitRight:Void->Void, ?enterRight:Void->Void, ?exitLeft:Void->Void, removeOnCompletion:Bool = false) {
		super(null, target, startTime, 0);
		this.enterLeft = enterLeft;
		this.exitRight = exitRight;
		this.enterRight = enterRight;
		this.exitLeft = exitLeft;
		this.removeOnCompletion = removeOnCompletion;
	}
	
	override public function onEnterLeft(count:Int):Void {
		trace("ENTER LEFT x" + count);
		
		if (enterLeft != null) {
			enterLeft();
		}
	}
	
	override public function onExitLeft(count:Int):Void {
		trace("EXIT LEFT x" + count);
		
		if (exitLeft != null) {
			exitLeft();
		}
	}
	
	override public function onEnterRight(count:Int):Void {
		trace("ENTER RIGHT x" + count);
		
		if (enterRight != null) {
			enterRight();
		}
	}
	
	override public function onExitRight(count:Int):Void {
		trace("EXIT RIGHT x" + count);
		
		if (exitRight != null) {
			exitRight();
		}
	}
	
	override public function onUpdate(time:Float):Void {
		
	}
}