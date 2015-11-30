package lycan.tests.demo;

import lycan.util.tree.EditableIntervalTree;
import lycan.util.tree.StaticIntervalTree;
import lycan.util.tree.Interval;

using lycan.util.ArrayExtensions;

// TODO implementing a timeline with a slider/scrubber would work well for this
class IntervalTreesDemo extends BaseDemoState {
	override public function create():Void {		
		super.create();
		
		// 10 intervals in [0...10 ... 90...100]
		var intervals = new Array<DemoInterval>();
		var i = 0;
		while (i < 10000) {
			intervals.push(new DemoInterval(i, i + 10));
			i += 10;
		}
		testForIntervals(intervals);
		
		// [90...100 ... 0...10]
		intervals.reverse();
		testForIntervals(intervals);
		
		// Random
		intervals.shuffle();
		testForIntervals(intervals);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		lateUpdate(dt);
	}
	
	private function testForIntervals(intervals:Array<DemoInterval>):Void {
		var staticTree = new StaticIntervalTree<DemoInterval>(intervals);
		var modifiableTree = new EditableIntervalTree();
		for (interval in intervals) {
			modifiableTree.insert(interval.start, interval.end);
		}
		
		for (i in 0...10) {
			var staticContained = [];
			var staticOverlaps = [];
			var staticPartialOverlaps = [];
			var staticPointOverlaps = [];
			var dynamicContained = [];
			var dynamicOverlaps = [];
			var dynamicPartialOverlaps = [];
			var dynamicPointOverlaps = [];
			var start = Math.random() * 5000;
			var end = 5000 + Math.random() * 5000;
			var point = Math.random() * 20000 - 10000;
			staticTree.findContained(start, end, staticContained);
			staticTree.findOverlaps(start, end, staticOverlaps);
			staticTree.findPartialOverlaps(start, end, staticPartialOverlaps);
			staticTree.stab(point, staticPointOverlaps);
			modifiableTree.findContained(start, end, dynamicContained);
			modifiableTree.findOverlaps(start, end, dynamicOverlaps);
			modifiableTree.findPartialOverlaps(start, end, dynamicPartialOverlaps);
			modifiableTree.stab(point, dynamicPointOverlaps);
			
			trace("=======================");
			trace("Static tree found " + staticContained.length + " intervals contained in the range [" + start + "," + end + "]: " + staticContained);
			trace("Dynamic tree found " + dynamicContained.length + " intervals contained in the range [" + start + "," + end + "]: " + dynamicContained);
			trace("Static tree found " + staticOverlaps.length + " intervals that overlap the range [" + start + "," + end + "]: " + staticOverlaps);
			trace("Dynamic tree found " + dynamicOverlaps.length + " intervals that overlap the range [" + start + "," + end + "]: " + dynamicOverlaps);
			trace("Static tree found " + staticPartialOverlaps.length + " intervals that overlap the ends of the range [" + start + "," + end + "]: " + staticPartialOverlaps);
			trace("Dynamic tree found " + dynamicPartialOverlaps.length + " intervals that overlap the ends of the range [" + start + "," + end + "]: " + dynamicPartialOverlaps);
			trace("Static tree found " + staticPointOverlaps.length + " intervals that overlap the point [" + point + "]: " + staticPointOverlaps);
			trace("Dynamic tree found " + dynamicPointOverlaps.length + " intervals that overlap the point [" + point + "]: " + dynamicPointOverlaps);
			trace("=======================");
		}
	}
}

class DemoInterval implements Interval {
	public var start:Float;
	public var end:Float;
	
	public inline function new(start:Float, end:Float) {
		this.start = start;
		this.end = end;
	}
	
	public function toString():String {
		return "[" + start + "," + end + "]";
	}
}