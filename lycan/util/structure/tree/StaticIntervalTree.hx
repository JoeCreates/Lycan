package lycan.util.structure.tree;

// Non-modifiable centers-based interval tree
// An interval tree allows for efficiently determining whether intervals overlap or contain other sets of intervals
// Based on the MIT licensed C++ implementation at https://github.com/ekg/intervaltree
class StaticIntervalTree<T:Interval> {
	private var intervals:Array<T> = new Array<T>();
	private var left:StaticIntervalTree<T> = null;
	private var right:StaticIntervalTree<T> = null;
	private var center:Float = 0;

	public function new(intervals:Array<T>, depth:Int = 16, minBucket:Int = 64, leftExtent:Float = 0, rightExtent:Float = 0, maxBucket:Int = 512) {
		Sure.sure(intervals != null && intervals.length > 0);
		Sure.sure(depth > 0);
		Sure.sure(minBucket > 0);
		Sure.sure(maxBucket > 0);

		depth--;
		if (depth == 0 || (intervals.length < minBucket && intervals.length < maxBucket)) {
			intervals.sort(startSorter);
			trace(intervals);
			this.intervals = intervals;
			return;
		}

		if (leftExtent == 0 && rightExtent == 0) {
			intervals.sort(startSorter);
		}

		var leftPivot = 0.0;
		var rightPivot = 0.0;

		if (leftExtent != 0 || rightExtent != 0) {
			leftPivot = leftExtent;
			rightPivot = rightExtent;
		} else {
			leftPivot = intervals[0].start;
			var maxEnd = intervals[0];
			for (interval in intervals) {
				if (interval.end > maxEnd.end) {
					maxEnd = interval;
				}
			}
			rightPivot = maxEnd.end;
		}

		center = intervals[Std.int(intervals.length / 2)].start;

		var lefts = new Array<T>();
		var rights = new Array<T>();

		for (interval in intervals) {
			if (interval.end < center) {
				lefts.push(interval);
			} else if (interval.start > center) {
				rights.push(interval);
			} else {
				this.intervals.push(interval);
			}
		}

		// Recursively create child trees
		if (lefts.length != 0) {
			left = new StaticIntervalTree<T>(lefts, depth, minBucket, leftPivot, center, maxBucket);
		}
		if (rights.length != 0) {
			right = new StaticIntervalTree<T>(rights, depth, minBucket, center, rightPivot, maxBucket);
		}
	}

	// Finds the intervals that overlap the point
	public function stab(point:Float, result:Array<T>):Void {
		findOverlaps(point, point, result);
	}

	// Finds the intervals that overlap the range
	public function findOverlaps(start:Float, end:Float, result:Array<T>):Void {
		if (intervals.length != 0 && end >= intervals[0].start) {
			for (interval in intervals) {
				if (interval.end >= start && interval.start <= end) {
					result.push(interval);
				}
			}
		}

		// Recursively search child trees
		if (left != null && start <= center) {
			left.findOverlaps(start, end, result);
		}
		if (right != null && end >= center) {
			right.findOverlaps(start, end, result);
		}
	}

	// Finds the intervals that overlap the start or end of the range
	public function findPartialOverlaps(start:Float, end:Float, result:Array<T>):Void {
		if (intervals.length != 0 && end >= intervals[0].start) {
			for (interval in intervals) {
				if (interval.start <= start && interval.end >= start || interval.start <= end && interval.end >= end) {
					result.push(interval);
				}
			}
		}

		// Recursively search child trees
		if (left != null && start <= center) {
			left.findPartialOverlaps(start, end, result);
		}
		if (right != null && end >= center) {
			right.findPartialOverlaps(start, end, result);
		}
	}

	// Finds the intervals that are contained within the range
	public function findContained(start:Float, end:Float, result:Array<T>):Void {
		if (intervals.length != 0 && end >= intervals[0].start) {
			for (interval in intervals) {
				if (interval.start >= start && interval.end <= end) {
					result.push(interval);
				}
			}
		}

		// Recursively search child trees
		if (left != null && start <= center) {
			left.findContained(start, end, result);
		}
		if (right != null && end >= center) {
			right.findContained(start, end, result);
		}
	}

	// Sorts intervals by start time
	private static function startSorter(a:Interval, b:Interval):Int {
		var v = a.start - b.start;
		if (v > 0) {
			return 1;
		}
		if (v < 0) {
			return -1;
		}
		return 0;
	}
}