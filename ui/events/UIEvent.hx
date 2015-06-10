package lycan.ui.events;

import lycan.ui.events.UIEvent.ChildEvent;
import lycan.ui.widgets.Widget;

import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.events.TouchEvent;

@:enum
abstract Type(Int) {
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
	var FocusIn = 10; // Widget gains the keyboard focus
	var FocusOut = 11; // Widget loses the keyboard focus
	var Gesture = 12; // A gesture was triggered
	var Hide = 13; // Widget was hidden
	var HoverEnter = 14; // Pointer enters a hoverable widget
	var HoverLeave = 15; // Pointer leaves a hoverable widget
	var HoverMove = 16; // Pointer moves inside a hoverable widget
	var LocaleChange = 17; // The app's locale changed
	var PointerPress = 18; // Pointer pressed
	var PointerRelease = 19; // Pointer released
	var PointerMove = 20; // Pointer moved
	var Move = 21; // Widget position changed
	var OrientationChange = 22; // The screen orientation changed
	var Resize = 23; // The widget size changed
	var Scroll = 24; // The object needs to scroll to a position
	var PropertyChanged = 25; // A widget's watch property changed
	var LayoutRequest = 26; // Widget layout needs to be redone
	var Leave = 27; // Pointer leaves the widgets boundaries
	var WheelScroll = 28; // The mouse wheel was scrolled
	// ZOrderChange; // The widget's z-order changed
}

class UIEvent {
	public var type(get, null):Type;
	public var accept:Bool = false;
	
	public function new(type:Type) {
		this.type = type;
	}
	
	public function get_type():Type {
		return type;
	}
	
	/*
	public function get_accept():Bool {
		return accept;
	}
	
	public function set_accept(accept:Bool):Bool {
		return this.accept = accept;
	}
	*/
	
	/*
	static public function registerEventType(hint:Int):Void {
	
	}
	*/
}

class ChildEvent extends UIEvent {
	public var child(get, null):Widget;
	
	public function new(type:Type, child:Widget) {
		super(type);
		this.child = child;
	}
	
	public function added():Bool {
		return type == Type.ChildAdded;
	}
	
	public function removed():Bool {
		return type == Type.ChildRemoved;
	}
	
	public function get_child():Widget {
		return child;
	}
}

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

class FocusInEvent extends UIEvent {
	
}

class FocusOutEvent extends UIEvent {
	
}

class GestureEvent extends UIEvent {
	
}

class HideEvent extends UIEvent {
	
}

class HoverEnterEvent extends UIEvent {
	
}

class HoverLeaveEvent extends UIEvent {
	
}

class HoverMoveEvent extends UIEvent {
	
}

class LocaleChangeEvent extends UIEvent {
	
}

class PointerEvent extends UIEvent {
	
}

class PropertyChangedEvent extends UIEvent {
	
}

class ResizeEvent extends UIEvent {
	
}

class WheelEvent extends UIEvent {
	
}