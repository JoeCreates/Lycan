package lycan.util.timeline;

import haxe.ds.ObjectMap;

using lycan.util.FloatExtensions;

typedef SortedTimelineItems = {
	var forwardSort:Array<TimelineItem>; // Items sorted from earliest start time to latest start time
	var reverseSort:Array<TimelineItem>; // Items sorted from latest end time to earliest end time
}

class Timeline<T:{}> extends TimelineItem {
	public var currentTime(default, set):Float;
	public var defaultRemoveCuesOnCompletion:Bool;
	private var items:ObjectMap<T, SortedTimelineItems>;
	
	public function new() {
		super(null, null, 0, 0);
		currentTime = 0;
		defaultRemoveCuesOnCompletion = false;
		useAbsoluteTime = true;
		items = new ObjectMap<T, SortedTimelineItems>();
	}
	
	// Step forward or backward on the timeline
	public function step(dt:Float):Void {
		currentTime += dt;
		super.stepTo(currentTime, dt < 0);
	}
	
	// Steps to the provided absolute time on the timeline
	// Items on each target will be triggered in order of their startTimes (earliest to latest) when stepping forward, and their endTimes (latest to earliest) when reversing
	// Note that this is a per-target object ordering, not a global ordering on all the items
	override public function stepTo(nextTime:Float, ?reverse:Bool):Void {
		nextTime = nextTime.clamp(0, duration);
		
		reverse = currentTime > nextTime;
		
		eraseMarked();
		
		var iter = items.iterator();
		for (items in iter) {
			var arr;
			if (reverse) {
				arr = items.reverseSort;
			} else {
				arr = items.forwardSort;
			}
			
			for (item in arr) {
				var needsStep:Bool;
				if (reverse) {
					needsStep = rangesIntersect(nextTime, currentTime, item.startTime, item.endTime);
				} else {
					needsStep = rangesIntersect(currentTime, nextTime, item.startTime, item.endTime);
				}
				
				if(needsStep) {
					item.stepTo(nextTime, reverse);
				}
				
				if (item.completed && item.removeOnCompletion) {
					item.markedForRemoval = true;
				}
			}
		}
		
		eraseMarked();
		
		currentTime = nextTime;
	}
	
	// Skip forward or backward to a place on the timeline without triggering any items
	public function skipTo(nextTime:Float):Void {
		currentTime = nextTime;
	}
	
	override public function update(absoluteTime:Float):Void {
		stepTo(absoluteTime);
	}
	
	public function addFunction(target:T, f:Void->Void, atTime:Float):Cue {
		var cue = new Cue(target, f, atTime);
		cue.removeOnCompletion = defaultRemoveCuesOnCompletion;
		add(cue);
		return cue;
	}
	
	public function add(item:TimelineItem):Void {
		Sure.sure(item != null);
		Sure.sure(item.target != null);
		
		item.parent = this;
		
		var existingItems = items.get(item.target);
		
		if (existingItems != null) {
			existingItems.forwardSort.push(item);
			existingItems.reverseSort.push(item);
		} else {
			existingItems = { forwardSort:[ item ], reverseSort:[ item ] };
			items.set(item.target, existingItems );
		}
		
		existingItems.forwardSort.sort(function(a:TimelineItem, b:TimelineItem):Int {
			if (a.startTime < b.startTime) {
				return -1;
			}
			if (a.startTime > b.startTime) {
				return 1;
			}
			return 0;
		});
		existingItems.reverseSort.sort(function(a:TimelineItem, b:TimelineItem):Int {
			if (a.endTime > b.endTime) {
				return -1;
			}
			if (a.endTime < b.endTime) {
				return 1;
			}
			return 0;
		});
		
		durationDirty = true;
	}
	
	public function addAtTime(item:TimelineItem, ?time:Float):Void {
		if(time == null) {
			item.startTime = currentTime;
		} else {
			item.startTime = time;
		}
		add(item);
	}
	
	public function find(target:T, byStartTime:Bool = true):Array<TimelineItem> {
		if (byStartTime) {
			return items.get(target).forwardSort;
		} else {
			return items.get(target).reverseSort;
		}
	}
	
	public function remove(itemToRemove:TimelineItem):Void {
		for (items in items.iterator()) {
			for (item in items.forwardSort) {
				if (item == itemToRemove) {
					item.markedForRemoval = true;
				}
			}
			for (item in items.reverseSort) {
				if (item == itemToRemove) {
					item.markedForRemoval = true;
				}
			}
		}
	}
	
	public function removeTarget(target:T):Void {
		if (target == null) {
			return;
		}
		
		var arr = items.get(target);
		for (item in arr.forwardSort) {
			item.markedForRemoval = true;
		}
		for (item in arr.reverseSort) {
			item.markedForRemoval = true;
		}
		
		durationDirty = true;
	}
	
	public function replaceTarget(target:T, replacement:T):Void {
		if (target == null) {
			return;
		}
		
		var arr = items.get(target);
		items.remove(target);
		
		if(arr != null) {
			items.set(replacement, arr);
		}
	}
	
	public function clear():Void {
		items = new ObjectMap<T, SortedTimelineItems>();
	}
	
	override public function reset(unsetStarted:Bool = false):Void {
		super.reset(unsetStarted);
		
		for (items in items.iterator()) {
			for (item in items.forwardSort) {
				item.reset(unsetStarted);
			}
		}
	}
	
	public function itemTimeChanged(item:TimelineItem):Void {
		durationDirty = true;
	}
	
	override public function onLoopStart():Void {
		reset(false);
	}
	
	private function eraseMarked():Void {
		for (items in items.iterator()) {
			for (item in items.forwardSort) {
				if (item.markedForRemoval) {
					items.forwardSort.remove(item);
				}
			}
			for (item in items.reverseSort) {
				if (item.markedForRemoval) {
					items.reverseSort.remove(item);
				}
			}
		}
		durationDirty = true;
	}
	
	override public function calcDuration():Float {
		var duration:Float = 0;
		for (items in items.iterator()) {
			for (item in items.forwardSort) {
				duration = Math.max(item.endTime, duration);
			}
		}
		return duration;
	}
	
	override public function get_endTime():Float {
		if (durationDirty) {
			duration = calcDuration();
		}
		return startTime + duration;
	}
	
	private function set_currentTime(time:Float):Float {
		return this.currentTime = time.clamp(0, duration);
	}
	
	private inline function rangesIntersect(x1:Float, x2:Float, y1:Float, y2:Float):Bool {		
		return x1 <= y2 && y1 <= x2;
	}
}