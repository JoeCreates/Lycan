package lycan.util.timeline;

import haxe.ds.ObjectMap;
import lycan.util.LinkedList;
import msignal.Signal.Signal0;

using lycan.util.FloatExtensions;

class Timeline<T:{}> extends TimelineItem {
	public var currentTime(default, set):Float;
	
	public var signal_reset(default, null) = new Signal0();
	
	private var map:ObjectMap<T, ListPair>;
	
	private var dirtyDuration:Bool; // TODO also the timeline should only be able to grow in duration, not shrink (except maybe on reset) - so need to keep track of max size
	
	public function new() {
		super(null, null, 0, 0);
		map = new ObjectMap<T, ListPair>();
		dirtyDuration = true;
		currentTime = 0;
	}
	
	// Step to a relative time on the timeline
	public function step(dt:Float):Void {
		stepTo(currentTime + dt, currentTime);
	}
	
	// Steps to an absolute time on the timeline
	// Items on each target are updated in order of their startTimes (earliest to latest) when stepping forward, and their endTimes (latest to earliest) when stepping backward
	// Note that this is a per-target object ordering, not a global ordering on all the items
	override public function stepTo(nextTime:Float, ?unusedCurrentTime:Float):Void {
		nextTime = nextTime.clamp(0, duration);
		
		removeMarked();
		
		var reversing:Bool = currentTime > nextTime;
		var iter = map.iterator();
		for (items in iter) {
			var list:LinkedList<TimelineItem> = items.getList(reversing);
			
			for (item in list) {
				Sure.sure(item.startTime <= item.endTime);
				if(rangesIntersect(currentTime, nextTime, item.startTime, item.endTime)) {
					item.stepTo(nextTime, currentTime);
				}
			}
		}
		
		removeMarked();
		
		currentTime = nextTime;
	}
	
	private inline function rangesIntersect(x1:Float, x2:Float, y1:Float, y2:Float):Bool {
		return ((Math.min(x1, x2) <= Math.max(y1, y2)) && (Math.min(y1, y2) <= Math.max(x1, x2)));
	}
	
	// Skip to an absolute time without triggering items
	public function skipTo(nextTime:Float):Void {
		currentTime = nextTime;
	}
	
	override public function onUpdate(absoluteTime:Float):Void {
		stepTo(absoluteTime);
	}
	
	public function addFunction(target:T, f:Int->Void, startTime:Float):Cue {
		Sure.sure(target != null);
		
		var cue = new Cue(target, startTime, f);
		insert(cue);
		return cue;
	}
	
	public function insert(item:TimelineItem):Void {
		Sure.sure(item != null);
		Sure.sure(item.target != null);
		Sure.sure(item.parent == null);
		
		item.parent = this;
		
		var items = map.get(item.target);
		
		// If the target isn't found then set a new entry for it
		if (items == null) {
			items = new ListPair(new LinkedList<TimelineItem>(), new LinkedList<TimelineItem>());
			map.set(item.target, items);
		}
		
		// If the target has no items then simply add one
		if (items.isEmpty()) {
			items.add(item);
			dirtyDuration = true;
			return;
		}
		
		var forwardList = items.getList(false);
		
		// TODO think about any implications regarding stability of insertions here (i.e. sitatuions where two items with identical start and end times might get called in mixed up orders?)
		
		if (forwardList.last().startTime < item.startTime) { // If the latest start time is earlier than the item's start time, add it to the end
			forwardList.add(item);
		} else { 
			var forwardInserted = forwardList.insertBefore(item, function(other:TimelineItem):Bool {
				Sure.sure(other != null);
				return other.startTime >= item.startTime; // Insert the item before the first item that starts later than it
			});
			Sure.sure(forwardInserted);
		}
		
		var backwardList = items.getList(true);
		if (backwardList.last().endTime > item.endTime) { // If the earliest end time is later than the item's end time, add it to the end
			backwardList.push(item);
		} else {
			var reverseInserted = backwardList.insertBefore(item, function(other:TimelineItem):Bool {
				Sure.sure(other != null);
				return other.endTime <= item.endTime; // Insert the item before the first item that is earlier than it
			});
			Sure.sure(reverseInserted);
		}
		
		dirtyDuration = true;
	}
	
	public function remove(item:TimelineItem):Void {
		Sure.sure(item != null);
		for (items in map.iterator()) {
			items.removeItem(item);
		}
	}
	
	public function removeTarget(target:T):Void {
		Sure.sure(target != null);
		if (target == null) {
			return;
		}
		
		map.remove(target);
	}
	
	public function replaceTarget(target:T, replacement:T):Void {
		Sure.sure(target != null && replacement != null);
		if (target == null) {
			return;
		}
		
		var items = map.get(target);
		map.remove(target);
		
		if(items != null) {
			map.set(replacement, items);
		}
	}
	
	public function clear():Void {
		map = new ObjectMap<T, ListPair>();
	}
	
	override public function reset():Void {
		super.reset();
		
		var iter = map.iterator();
		for (items in iter) {
			var list = items.getList(false);
			for (item in list) {
				item.reset();
			}
		}
		
		signal_reset.dispatch();
	}
	
	public function itemTimeChanged(item:TimelineItem):Void {
		Sure.sure(item != null);
		dirtyDuration = true;
	}
	
	private function removeMarked():Void {
		var iter = map.iterator();
		for (items in iter) {
			var list = items.getList(false);
			for (item in list) {
				if (item.markedForRemoval) {
					list.remove(item);
				}
			}
		}
	}
	
	private function set_currentTime(time:Float):Float {
		return this.currentTime = time.clamp(0, duration);
	}
	
	override private function get_duration():Float {
		if (dirtyDuration) {
			var duration:Float = 0;
			var iter = map.iterator();
			for (items in iter) {
				var list = items.getList(false);
				if (!list.isEmpty()) {
					duration = Math.max(duration, list.last().endTime);
				}
				this.duration = duration.clamp(0, duration);
			}
			dirtyDuration = false;
		}
		
		return this.duration;
	}
}

// Wraps two sorted lists of timeline items
// One list is sorted by earliest to latest start times, and another from latest to earliest end times
class ListPair {
	public function new(forwardSort:LinkedList<TimelineItem>, reverseSort:LinkedList<TimelineItem>) {
		this.forwardList = forwardSort;
		this.backwardList = reverseSort;
		sanityCheck();
	}
	
	private var forwardList:LinkedList<TimelineItem>; // Items sorted from earliest start time to latest start time
	private var backwardList:LinkedList<TimelineItem>; // Items sorted from latest end time to earliest end time
	
	public inline function getList(backward:Bool):LinkedList<TimelineItem> {
		if (backward) {
			return backwardList;
		} else {
			return forwardList;
		}
	}
	
	public inline function isEmpty():Bool {
		return (forwardList.isEmpty() && backwardList.isEmpty());
	}
	
	public inline function add(item:TimelineItem):Void {
		forwardList.add(item);
		backwardList.add(item);
	}
	
	public function removeItem(itemToRemove:TimelineItem):Bool {
		sanityCheck();
		for (item in forwardList) {
			if (item == itemToRemove) {
				item.markedForRemoval = true;
				return true;
			}
		}
		return false;
	}
	
	public inline function sanityCheck():Void {
		Sure.sure(forwardList.length == backwardList.length);
	}
}