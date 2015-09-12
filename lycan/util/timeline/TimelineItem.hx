package lycan.util.timeline;

using lycan.util.BitSet;

using lycan.util.FloatExtensions;

// Base class for anything that can go on a timeline
class TimelineItem {
	public var parent(default, null):Timeline<Dynamic>;
	public var target(default, set):Dynamic;
	
	public var startTime(default, set):Float;
	@:isVar public var duration(get, set):Float;
	public var endTime(get, null):Float;
	
	public var enterLeftCount:Int;
	public var exitLeftCount:Int;
	public var enterRightCount:Int;
	public var exitRightCount:Int;
	public var stepOverCount:Int;
	
	public var exitLeftLimit(default, null):Int;
	public var exitRightLimit(default, null):Int;
	public var completed(get, null):Bool;
	
	public var removeOnCompletion(default, default):Bool;
	public var markedForRemoval(default, default):Bool;
	
	public function new(?parent:Timeline<Dynamic>, target:Dynamic, startTime:Float, duration:Float) {
		this.parent = parent;
		this.target = target;
		this.startTime = startTime;
		this.duration = duration;
		
		enterLeftCount = 0;
		exitLeftCount = 0;
		enterRightCount = 0;
		exitRightCount = 0;
		stepOverCount = 0;
		
		exitLeftLimit = 1;
		exitRightLimit = 1;
		
		removeOnCompletion = true;
		markedForRemoval = false;
	}
	
	public function reset():Void {
		enterLeftCount = 0;
		exitLeftCount = 0;
		enterRightCount = 0;
		exitRightCount = 0;
		stepOverCount = 0;
		markedForRemoval = false;
	}
	
	public function onEnterLeft(count:Int):Void {
		
	}
	
	public function onExitLeft(count:Int):Void {
		
	}
	
	public function onEnterRight(count:Int):Void {
		
	}
	
	public function onExitRight(count:Int):Void {
		
	}
	
	public function onUpdate(time:Float):Void {
		stepTo(time);
	}
	
	public function stepTo(nextTime:Float, ?currentTime:Float):Void {
		Sure.sure(currentTime != null);
		
		if (markedForRemoval) {
			return;
		}
		
		if (completed) {
			if (removeOnCompletion) {
				markedForRemoval = true;
			}
			return;
		}
		
		var enteredLeft:Bool = (currentTime <= startTime && nextTime > startTime);
		var enteredRight:Bool = (currentTime >= endTime && nextTime < endTime);
		var exitedLeft:Bool = (currentTime >= startTime && nextTime < startTime);
		var exitedRight:Bool = (currentTime <= endTime && nextTime > endTime);
		
		if (enteredLeft) {
			onEnterLeft(enterLeftCount++);
		}
		if (enteredRight) {
			onEnterRight(enterRightCount++);
		}
		
		if (exitedLeft) {
			onExitLeft(exitLeftCount++);
		}
		if (exitedRight) {
			onExitRight(exitRightCount++);
		}
	}
	
	private function set_target(target:Dynamic):Dynamic {
		return this.target = target;
	}
	
	private function get_duration():Float {
		return this.duration;
	}
	
	private function set_duration(duration:Float):Float {
		this.duration = Math.max(0, duration);
		if (parent != null) {
			parent.itemTimeChanged(this);
		}
		return duration;
	}
	
	private function set_startTime(startTime:Float):Float {
		this.startTime = startTime;
		if (parent != null) {
			parent.itemTimeChanged(this);
		}
		return startTime;
	}
	
	private function get_endTime():Float {
		return startTime + duration;
	}
	
	private function get_completed():Bool {
		return (exitLeftCount >= exitLeftLimit && exitRightCount >= exitRightLimit);
	}
}