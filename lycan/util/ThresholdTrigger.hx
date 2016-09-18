package lycan.util;

import msignal.Signal.Signal2;

using lycan.core.ArrayExtensions;
using lycan.core.IntExtensions;

interface Threshold {
	public var threshold(default, null):Float;
	public var signal_crossed(default, null):Signal2<Float, Float>;
	public function precondition(before:Float, after:Float):Bool;
}

// Threshold that always triggers whenever it is crossed
class SimpleThreshold implements Threshold {
	public var signal_crossed(default, null) = new Signal2<Float, Float>();
	public var threshold(default, null):Float;

	public function new(threshold:Float, ?cbs:Array<Float->Float->Void>) {
		this.threshold = threshold;

		if (cbs != null) {
			for (cb in cbs) {
				signal_crossed.add(cb);
			}
		}
	}
	
	public function precondition(before:Float, after:Float):Bool {
		return true;
	}
}

// Threshold that triggers up to n times when it is crossed below or above the threshold
class CountedBidirectionalThreshold implements Threshold {
	public var signal_crossed(default, null) = new Signal2<Float, Float>();
	public var threshold(default, null):Float;
	public var belowTriggerCountdown(default, null):Int;
	public var aboveTriggerCountdown(default, null):Int;
	
	public function new(threshold:Float, ?cbs:Array<Float->Float->Void>, belowTriggerCountdown:Int = 1, aboveTriggerCountdown:Int = 1) {
		this.threshold = threshold;
		if (cbs != null) {
			for (cb in cbs) {
				signal_crossed.add(cb);
			}
		}
	}
	
	public function reset(downs:Int = 1, ups:Int = 1) {
		this.belowTriggerCountdown = downs;
		this.aboveTriggerCountdown = ups;
	}
	
	public function precondition(before:Float, after:Float):Bool {
		if (after < before) {
			if (belowTriggerCountdown-- >= 0) {
				return true;
			}
		} else {
			if (aboveTriggerCountdown-- >= 0) {
				return true;
			}
		}
		return false;
	}
}

// This watches a value and dispatches signals when thresholds are crossed due to that value changing
class ThresholdTrigger<T:Threshold> {
	public var value(default, set):Float;
	private var thresholds = new Array<T>();

	public function new(initialValue:Float) {
		this.value = initialValue;
	}

	public function add(o:T):Void {
		if (thresholds.length == 0) {
			thresholds.push(o);
			return;
		}

		var idx = thresholds.binarySearchCmpNumeric(o.threshold, 0, thresholds.length - 1, comp);
		if (idx < 0) {
			idx = ~idx;
		}

		thresholds.insert(idx, o);
	}

	private function comp(a:T, b:Float):Int {
		if (a.threshold < b) {
			return -1;
		}
		if (a.threshold > b) {
			return 1;
		}
		return 0;
	}

	private function set_value(v:Float):Float {
		if (v == this.value) {
			return this.value;
		}

		if (thresholds.length == 0) {
			return this.value = v;
		}

		var lower = thresholds.binarySearchCmpNumeric(Math.min(v, this.value), 0, thresholds.length - 1, comp);
		var upper = thresholds.binarySearchCmpNumeric(Math.max(v, this.value), 0, thresholds.length - 1, comp);
		if (lower < 0) {
			lower = ~lower;
		}
		if (upper < 0) {
			upper = ~upper;
		}

		for (i in lower...upper) {
			if(thresholds[i].precondition(this.value, v)) {
				thresholds[i].signal_crossed.dispatch(this.value, v);
			}
		}

		return this.value = v;
	}
}