package lycan.util.timeline;

// Base class for anything that can go on a timeline
class TimelineItem {	
	public var parent(default, null):Timeline;
	public var target(default, set):Dynamic;
	public var startTime(default, set):Float;
	public var duration(default, set):Float;
	public var looping(default, default):Bool;
	public var pingPong(default, default):Bool;
	public var infinite(default, default):Bool;
	public var endTime(get, null):Float;
	public var started(default, null):Bool;
	public var reverseStarted(default, null):Bool;
	public var completed(default, null):Bool;
	public var reverseCompleted(default, null):Bool;
	public var autoRemove(default, default):Bool;
	public var updateAtLoopStart(get, null):Bool;
	
	private var markedForRemoval(default, default):Bool;
	private var useAbsoluteTime(default, default):Bool;
	private var lastLoopIteration(default, default):Int;
	private var inverseDuration(default, default):Float;
	private var dirtyDuration(default, set):Bool;
	
	public function new(?parent:Timeline, ?target:Dynamic, startTime:Float, duration:Float) {
		this.parent = parent;
		this.target = target;
		this.startTime = startTime;
		this.duration = duration;
		looping = false;
		pingPong = false;
		infinite = false;
		started = false;
		reverseStarted = false;
		completed = false;
		reverseCompleted = false;
		autoRemove = true;
		
		markedForRemoval = false;
		useAbsoluteTime = false;
		lastLoopIteration = -1;
		inverseDuration = 0;
		dirtyDuration = false;
	}
	
	public function removeSelf():Void {
		markedForRemoval = true;
	}
	
	public function reset(unsetStarted:Bool = false):Void {
		if (unsetStarted) {
			started = false;
			completed = false;
		}
	}
	
	public function start(reverse:Bool):Void {
		
	}
	
	public function loopStart():Void {
		
	}
	
	public function update(relativeTime:Float):Void {
		
	}
	
	public function complete(reverse:Bool):Void {
		
	}
	
	public function calcDuration():Float {
		return duration;
	}
	
	public function reverse():Void {
		
	}
	
	public function stepTo(newTime:Float, ?reverse:Bool):Void {
		if (reverse == null) {
			reverse = false;
		}
		
		if (markedForRemoval) {
			return;
		}
		
		updateDuration();
		
		var absTime:Float = newTime - startTime;
		var endTime:Float = startTime + duration;
		
		if (!reverseStarted && reverse && (newTime < startTime)) {
			if (useAbsoluteTime) {
				update(startTime);
			} else {
				update(0);
			}
			
			reverseStarted = true;
			started = true;
			start(true);
		} else if (newTime >= startTime) {
			var relTime:Float = 0;
			if (pingPong) {
				relTime = fmod(absTime * inverseDuration, 2);
				if (relTime > 1) {
					relTime = (2 - relTime);
				}
			} else if (looping) {
				relTime = fmod(absTime * inverseDuration, 1);
			} else {
				relTime = Math.min(absTime * inverseDuration, 1);
			}
			
			if (!started && !reverse) {
				started = true;
				reverseStarted = false;
				lastLoopIteration = 0;
				loopStart();
				start(false);
			}
			
			var time:Float;
			if (useAbsoluteTime) {
				time = absTime;
			} else {
				time = relTime;
			}
			
			if (!useAbsoluteTime && (inverseDuration <= 0)) {
				time = 1.0;
			}
			
			if (looping || pingPong) {
				var loopIteration:Int = Std.int((newTime - startTime) * inverseDuration);
				
				if (loopIteration != lastLoopIteration) {
					lastLoopIteration = loopIteration;
					loopStart();
					update(time);
				} else {
					update(time);
				}
			} else {
				update(time);
			}
		}
		
		if (newTime < endTime) {
			if (!reverseCompleted && reverse) {
				reverseCompleted = true;
				completed = false;
				complete(true);
			}
		} else if (!looping && !infinite) {
			if (!completed && !reverse) {
				completed = true;
				reverseCompleted = false;
				complete(false);
			}
		}
	}
	
	private function updateDuration():Void {
		if (dirtyDuration) {
			duration = Math.max(calcDuration(), 0.0);
			inverseDuration = (duration == 0) ? 1.0 : (1.0 / duration);
			dirtyDuration = false;
		}
	}
	
	private function loopTime(absoluteTime:Float):Float {
		var result = absoluteTime;
		if (pingPong) {
			result = fmod(result * inverseDuration, 2);
			
			if (result <= 1) {
				result *= duration;
			} else {
				result = (2 - result) * duration;
			}
		} else if (looping) {
			result = fmod(result * inverseDuration, 1);
			result *= duration;
		}
		return result;
	}
	
	private function set_target(target:Dynamic):Dynamic {
		return this.target = target;
	}
	
	private function set_duration(duration:Float):Float {
		this.duration = duration;
		inverseDuration = duration == 0 ? 1.0 : (1.0 / duration);
		if (parent != null) {
			parent.itemTimeChanged(this);
		}
		return duration;
	}
	
	private function set_dirtyDuration(dirty:Bool):Bool {
		return this.dirtyDuration = dirty;
	}
	
	private function set_startTime(startTime:Float):Float {
		this.startTime = startTime;
		if (parent != null) {
			parent.itemTimeChanged(this);
		}
		return startTime;
	}
	
	private function get_endTime():Float {
		return endTime + duration;
	}
	
	private function get_updateAtLoopStart():Bool {
		return false;
	}
	
	private static inline function fmod(a:Float, b:Float):Float {
		return (a - b * Math.floor(a / b));
	}
}