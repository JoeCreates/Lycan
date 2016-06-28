package lycan.ui.core;

import flixel.math.FlxPoint;
import lycan.ui.widgets.Widget.Direction;

@:enum abstract GestureType(Int) {
	var Tap = 1;
	var TapAndHold = 2;
	var Pan = 3;
	var Pinch = 4;
	var Swipe = 5;
	// TODO custom types
}

enum GestureState {
	Started;
	Updated;
	Finished;
	Cancelled;
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
	
	public var position(default, null):FlxPoint;
}

class LongPressGesture extends Gesture {
	public function new() {
		super(TapAndHold);
	}
	
	public var position(default, null):FlxPoint;
	public var timeout(default, null):Float;
}

class PanGesture extends Gesture {
	public function new() {
		super(Pan);
	}
	
	public var delta(default, null):FlxPoint;
	public var lastOffset(default, null):FlxPoint;
	public var offset(default, null):FlxPoint;
}

class PinchGesture extends Gesture {
	public function new() {
		super(Pinch);
	}
	
	public var startCenter(default, null):FlxPoint;
	public var lastCenter(default, null):FlxPoint;
	public var center(default, null):FlxPoint;
	public var totalScaleFactor(default, null):Float;
	public var lastScaleFactor(default, null):Float;
	public var scaleFactor(default, null):Float;
	public var totalRotationAngle(default, null):Float;
	public var lastRotationAngle(default, null):Float;
	public var rotationAngle(default, null):Float;
}

class SwipeGesture extends Gesture {
	public function new() {
		super(Swipe);
	}
	
	public var swipeDirection(default, null):Direction;
	public var swipeAngle(default, null):Float;
}