package lycan.ui.events;

import haxe.Utf8;
import lycan.ui.core.Gesture;
import lycan.ui.events.UIEvent.ChildEvent;
import lycan.ui.events.UIEvent.WheelEvent;
import lycan.ui.pointer.MouseButton;

// TODO macro to just make the enum values increase rather than specifying values manually?
// TODO macro to add additional user/game-specific events onto the 1000+ range or whatever?
@:enum
abstract EventType(Int) {
	var None = 0;
	var ChildAdded = 1; // Object gets a child
	var ChildRemoved = 2; // Object loses a child
	var Close = 3; // Widget is closed
	var DragEnter = 4; // Pointer enters a widget during a drag and drop
	var DragLeave = 5; // Pointer leaves a widget during a drag and drop
	var DragMove = 6; // A drag and drop operation is in progress
	var Drop = 7; // A drag and drop operation completes
	var EnabledChange = 8; // The widget's enabled/disabled state changed
	var Enter = 9; // Pointer enters the widget
	var KeyboardFocusIn = 10; // Widget gains the keyboard focus
	var KeyboardFocusOut = 11; // Widget loses the keyboard focus
	var Gesture = 12; // A gesture was triggered
	var Show = 13; // Widget was shown
	var Hide = 14; // Widget was hidden
	var HoverEnter = 15; // Pointer enters a hoverable widget
	var HoverLeave = 16; // Pointer leaves a hoverable widget
	var HoverMove = 17; // Pointer moves inside a hoverable widget
	var LocaleChange = 18; // The app's locale changed
	var PointerPress = 19; // Pointer pressed
	var PointerRelease = 20; // Pointer released
	var PointerMove = 21; // Pointer moved
	var Move = 22; // Widget position changed
	var OrientationChange = 23; // The screen orientation changed
	var Resize = 24; // The widget size changed
	var Scroll = 25; // The object needs to scroll to a position
	var PropertyChange = 26; // A widget's watch property changed
	var LayoutRequest = 27; // Widget layout needs to be redone
	var Leave = 28; // Pointer leaves the widgets boundaries
	var WheelScroll = 29; // The mouse wheel was scrolled
	var KeyPress = 30; // Key pressed down
	var KeyRelease = 31; // Key released

	var GamepadButtonDown = 32; // Gamepad button pressed down
	var GamepadButtonUp = 33; // Gamepad button released
	var GamepadConnect = 34; // Gamepad connected/detected
	var GamepadDisconnect = 35; // Gamepad disconnected
	var GamepadAxisMove = 36; // Gamepad analog stick moved

	var GamepadFocusIn = 37; // Widget gains the gamepad focus
	var GamepadFocusOut = 38; // Widget loses the gamepad focus

	var AccelerometerUpdate = 39; // An accelerometer sent an update

	// ZOrderChange; // The widget's z-order changed
}

// Base of event classes. Events are generally passed from the input system to UI objects to handle.
class UIEvent {
	public var type(get, null):EventType;

	public function new(type:EventType) {
		this.type = type;
	}

	private function get_type():EventType {
		return type;
	}

	/*
	// For extending the Type enum with user generated events
	static public function registerEventType(hint:Int):Void {

	}
	*/
}

class ChildEvent extends UIEvent {
	public var child(get, null):UIObject;

	public function new(type:EventType, child:UIObject) {
		super(type);
		this.child = child;
	}

	public function added():Bool {
		return type == EventType.ChildAdded;
	}

	public function removed():Bool {
		return type == EventType.ChildRemoved;
	}

	private function get_child():UIObject {
		return child;
	}
}

// NOTE in theory all of these event types could be implemented just by passing the right data, so don't expose the OpenFL events passed into them, so that the system will be flexible enough to work with alternative different input systems
class CloseEvent extends UIEvent {

}

class DragEnterEvent extends UIEvent {

}

class DragLeaveEvent extends UIEvent {

}

class DragMoveEvent extends UIEvent {

}

class DropEvent extends UIEvent {

}

class EnabledChangeEvent extends UIEvent {

}

class EnterEvent extends UIEvent {

}

class KeyboardFocusEvent extends UIEvent {

}

class GamepadFocusEvent extends UIEvent {

}

class GestureEvent extends UIEvent {
	public var gesture(default, null):Gesture;

	public function new(gesture:Gesture) {
		super(EventType.Gesture);
		this.gesture = gesture;
	}
}

class ShowEvent extends UIEvent {

}

class HideEvent extends UIEvent {

}

class HoverEvent extends UIEvent {

}

class LocaleChangeEvent extends UIEvent {

}

class PointerEvent extends UIEvent {
	public var button:MouseButton;
	public var localX:Float;
	public var localY:Float;
	public var globalX:Float;
	public var globalY:Float;
}

class PropertyChangeEvent extends UIEvent {

}

class ResizeEvent extends UIEvent {

}

class WheelEvent extends UIEvent {
	public var delta:Int;

	public function new(delta:Int) {
		super(EventType.WheelScroll);
		this.delta = delta;
	}
}

class KeyEvent extends UIEvent {
	public var charCode:UInt;
	public var keyCode:UInt;

	public function text():String {
		// TODO this may flake for foreign/weird keyboards, and obviously lots of key events don't have glyphs that we can display
		var u = new Utf8();
		u.addChar(charCode);
		return u.toString();
	}
}

class MoveEvent extends UIEvent {

}

class GamepadEvent extends UIEvent {
	public function new(type:EventType) {
		super(type);
	}
}

class AccelerometerEvent extends UIEvent {

}