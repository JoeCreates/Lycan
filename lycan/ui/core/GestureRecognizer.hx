package lycan.ui.core;

import flixel.math.FlxPoint;

@:enum
abstract GestureType(Int) {
	var Tap = 1;
	var TapAndHold = 2;
	var Pan = 3;
	var Pinch = 4;
	var Swipe = 5;
	// TODO custom types
}

@:enum
abstract GestureState(Int) {
	var Started = 1;
	var Updated = 2;
	var Finished = 3;
	var Cancelled = 4;
}

// Infrastructure for gesture recognition
class GestureRecognizer {
	public function new() {
		
	}
}

class Gesture {
	public function new(type:GestureType) {
		this.type = type;
	}
	
	public var type(default, null):GestureType;
	
	public var hasHotspot(default, null):Bool;
	public var hotspot(get, null):FlxPoint; // UI coordinate used for finding the receiver for the gesture event
	
	private function get_hotspot():FlxPoint {
		Sure.sure(hasHotspot);
		return hotspot;
	}
}

class TapGesture extends Gesture {
	public function new() {
		super(Tap);
	}
}

class TapAndHoldGesture extends Gesture {
	public function new() {
		super(TapAndHold);
	}
}

class PanGesture extends Gesture {
	public function new() {
		super(Pan);
	}
	
	private var delta:FlxPoint;
	private var lastOffset:FlxPoint;
	private var offset:FlxPoint;
}

class PinchGesture extends Gesture {
	public function new() {
		super(Pinch);
	}
}

class SwipeGesture extends Gesture {
	public function new() {
		super(Swipe);
	}
}