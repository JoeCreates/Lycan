package lycan.util.timeline;
import msignal.Signal;
import msignal.Signal.Signal1;

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
	public var hovered(get, null):Bool;
	
	public var removeOnCompletion(default, default):Bool;
	public var markedForRemoval(default, default):Bool;
	
	// TODO lazy initialize?
	public var signal_enterLeft = new Signal1<Int>();
	public var signal_exitLeft = new Signal1<Int>();
	public var signal_enterRight = new Signal1<Int>();
	public var signal_exitRight = new Signal1<Int>();
	public var signal_removed = new Signal1<Timeline<Dynamic>>();
	
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
		
		#if debug
		signal_removed.add(function(parent:Timeline<Dynamic>) {
			trace("Removed timeline item from timeline");
		});
		#end
	}
	
	public function reset():Void {
		enterLeftCount = 0;
		exitLeftCount = 0;
		enterRightCount = 0;
		exitRightCount = 0;
		stepOverCount = 0;
		markedForRemoval = false;
	}
	
	public function onUpdate(time:Float):Void {
		
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
		var exitedLeft:Bool = (currentTime > startTime && nextTime < startTime);
		var exitedRight:Bool = (currentTime < endTime && nextTime > endTime);
		
		if (enteredLeft) {
			signal_enterLeft.dispatch(++enterLeftCount);
		}
		if (enteredRight) {
			signal_enterRight.dispatch(++enterRightCount);
		}
		
		if (exitedLeft) {
			signal_exitLeft.dispatch(++exitLeftCount);
		}
		if (exitedRight) {
			signal_exitRight.dispatch(++exitRightCount);
		}
		
		onUpdate(nextTime);
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
	
	private function get_hovered():Bool {
		Sure.sure(parent != null);
		return (parent.currentTime >= startTime && parent.currentTime <= endTime);
	}
}