package lycan.ui.core;

import lycan.ui.core.Gesture;
import lycan.ui.events.UIEvent;
import lycan.ui.UIObject;
import lycan.util.structure.container.ArraySet;

// The current result of the event filtering step in the gesture recognizer
@:enum abstract GestureRecognizerResult(Int) {
	var Ignore = 1;
	var Indeterminate = 2;
	var TriggerGesture = 4;
	var CancelGesture = 8;
}

// Infrastructure for gesture recognition
// A gesture recognizer is a frontend to a gesture manager that converts input events into higher-level actions
// Widgets subscribe to a gesture recognizer which then listens to their events
class GestureRecognizer {
	public function new() {

	}

	//public function create(target:UIObject):Gesture {
	//
	//}

	public function recognize(gesture:Gesture, watched:UIObject, event:UIEvent):GestureRecognizerResult {
		return Ignore;
	}

	public function reset(gesture:Gesture):Void {

	}
}

private class GestureManager {
	public static var instance(get, null):GestureManager;

	public function new() {

	}

	private var activeGestures:ArraySet<Gesture>;
	private var possibleGestures:ArraySet<Gesture>;

	private static function get_instance():GestureManager {
		if (instance == null) {
			instance = new GestureManager();
		}
		return instance;
	}
}