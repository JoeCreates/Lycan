package lycan.ui.widgets;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import lycan.ui.events.UIEvent;
import lycan.ui.layouts.Layout;
import lycan.ui.layouts.SizePolicy;
import lycan.ui.UIObject;
import Sure;

enum Direction {
	Left;
	Up;
	Right;
	Down;
}

enum KeyboardFocusReason {
	ClickFocusReason;
	TabFocusReason;
	PopupFocusReason;
	ShortcutFocusReason;
	WheelFocus;
	OtherFocusReason;
}

enum GamepadFocusReason {
	PopupFocusReason;
	OtherFocusReason;
}

enum KeyboardFocusPolicy {
	ClickFocus;
	TabFocus;
	WheelFocus;
	StrongFocus;
	NoFocus;
}

enum GamepadFocusPolicy {
	ButtonFocus;
	AnalogStickFocus;
	StrongFocus;
	NoFocus;
}

class Widget extends UIObject {
	public var layout:Layout = null;
	public var enabled:Bool = true;
	public var modal:Bool = false;
	public var x(default, set):Int = 0;
	public var y(default, set):Int = 0;
	public var width:Int = 0;
	public var height:Int = 0;
	public var sizePolicy:SizePolicy; // TODO
	public var keyboardFocusPolicy:KeyboardFocusPolicy = KeyboardFocusPolicy.NoFocus;
	public var gamepadFocusPolicy:GamepadFocusPolicy = GamepadFocusPolicy.NoFocus;
	public var minWidth:Int = 0;
	public var minHeight:Int = 0;
	public var maxWidth:Int = 10000;
	public var maxHeight:Int = 10000;
	public var sizeIncrement:FlxPoint = FlxPoint.get(1, 1);
	public var keyboardFocus:Bool = false;
	public var gamepadFocus:Bool = false;
	public var shown:Bool = true;
	public var acceptDrops:Bool = true;
	public var paddingLeft:Int = 2;
	public var paddingTop:Int = 2;
	public var paddingRight:Int = 2;
	public var paddingBottom:Int = 2;
	public var marginLeft:Int = 2;
	public var marginTop:Int = 2;
	public var marginRight:Int = 2;
	public var marginBottom:Int = 2;
	
	public var hoverable:Bool = true;
	public var selectable:Bool = true;
	
	// TODO multitouch?
	// TODO should probably use gesture detectors for multitouch and propagate them as events to widgets
	
	public function new(?parent:UIObject = null, ?name:String) {
		super(parent, name);
		
		#if debug
		if(name == null) {
			this.name = Type.getClassName(Type.getClass(this));
		}
		#end
	}
	
	public function getNearestSelectableForDirection(direction:Direction, wrapAround:Bool = true):Widget {
		// TODO either iterate over the entire widget tree or pass the root object in? e.g. specifying a list widget will cause it to search only in the list items
		// Should be useful for gamepads
		// TODO could delegate this to layouts?
		return null;
	}
	
	// The area that contains the child widgets without inner padding
	// This is the area inside which widget contents may be positioned
	public function innerRect():FlxRect {
		return FlxRect.get(x + ((paddingLeft + paddingRight) / 2), y + ((paddingBottom + paddingTop) / 2), width - paddingLeft - paddingRight, height - paddingBottom - paddingTop);
	}
	
	// The area that contains the child widgets including inner padding
	public function borderRect():FlxRect {
		return FlxRect.get(x, y, width, height);
	}
	
	// The area that contains the child widget including inner padding and outer margins
	// This is the area that the layout manager should consider when laying out widgets within a layout
	public function outerRect():FlxRect {
		return FlxRect.get(x - ((marginLeft + marginRight) / 2), y - ((marginBottom + marginTop) / 2), width + marginLeft + marginRight, height + marginBottom + marginTop);
	}
	
	// The center of the innerRect
	public function innerCenter():FlxPoint {
		var innerRect = innerRect();
		return FlxPoint.get(innerRect.x + innerRect.width / 2, innerRect.y + innerRect.height / 2); // TODO avoid FlxPoint and minimize calculation
	}
	
	public function updateGeometry() {
		// Invalidates the current layout
		if(layout != null) {
			layout.dirty = true;
		}
		
		// Mark this and all parent objects as dirty
		var p = cast(this, UIObject);
		while (true) {
			p.dirty = true;
			
			if (p.parent != null) {
				p = p.parent;
			} else {
				break;
			}
		}
		
		// Ask the top-level object to recalculate the geometries of the dirty objects
		p.event(new UIEvent(EventType.LayoutRequest));
	}
	
	public function close() {
		
	}
	
	override public function event(e:UIEvent):Bool {
		switch(e.type) {
			case EventType.PointerPress:
				pointerPressEvent(cast e);
			case EventType.PointerMove:
				pointerMoveEvent(cast e);
			case EventType.PointerRelease:
				pointerReleaseEvent(cast e);
			case EventType.WheelScroll:
				wheelEvent(cast e);
			case EventType.KeyPress:
				keyPressEvent(cast e);
			case EventType.KeyRelease:
				keyReleaseEvent(cast e);
			case EventType.KeyboardFocusIn:
				keyboardFocusInEvent(cast e);
			case EventType.KeyboardFocusOut:
				keyboardFocusOutEvent(cast e);
			case EventType.HoverEnter:
				hoverEnterEvent(cast e);
			case EventType.HoverLeave:
				hoverLeaveEvent(cast e);
			case EventType.Move:
				moveEvent(cast e);
			case EventType.Resize:
				resizeEvent(cast e);
			case EventType.Close:
				closeEvent(cast e);
			case EventType.DragEnter:
				dragEnterEvent(cast e);
			case EventType.DragLeave:
				dragLeaveEvent(cast e);
			case EventType.Drop:
				dropEvent(cast e);
			case EventType.Show:
				showEvent(cast e);
			case EventType.Hide:
				hideEvent(cast e);
			case EventType.LocaleChange:
				localeChangeEvent(cast e);
			case EventType.PropertyChange:
				propertyChangeEvent(cast e);
			case EventType.LayoutRequest:
				layoutRequestEvent(cast e);
			case EventType.GamepadFocusIn:
				gamepadFocusInEvent(cast e);
			case EventType.GamepadFocusOut:
				gamepadFocusOutEvent(cast e);
			case EventType.GamepadAxisMove:
				gamepadAxisMoveEvent(cast e);
			case EventType.GamepadButtonDown:
				gamepadButtonDownEvent(cast e);
			case EventType.GamepadButtonUp:
				gamepadButtonUpEvent(cast e);
			case EventType.GamepadConnect:
				gamepadConnectEvent(cast e);
			case EventType.GamepadDisconnect:
				gamepadDisconnectEvent(cast e);
			default:
				return super.event(e);
		}
		
		return true;
	}
	
	public function setKeyboardFocus(reason:KeyboardFocusReason) {
		if (!enabled) {
			return;
		}
	}
	
	public function setGamepadFocus(reason:GamepadFocusReason) {
		if (!enabled) {
			return;
		}
	}
	
	public function clearKeyboardFocus() {
		
	}
	
	public function clearGamepadFocus() {
		
	}
	
	// TODO Steal ALL keyboard input until release
	public function grabKeyboard() {
		
	}
	
	// TODO Steal ALL gamepad input until release
	public function grabGamepad() {
		
	}
	
	public function releaseKeyboard() {
		
	}
	
	public function releaseGamepad() {
		
	}
	
	private function focusNextChild():Bool {
		return false;
	}
	
	private function focusPreviousChild():Bool {
		return false;
	}
	
	private function pointerPressEvent(e:PointerEvent) {
		#if debug
		trace(name + " received pointer press");
		#end
	}
	
	private function pointerReleaseEvent(e:PointerEvent) {
		#if debug
		trace(name + " received pointer release");
		#end
	}
	
	private function pointerMoveEvent(e:PointerEvent) {
		#if debug
		trace(name + " received pointer move");
		#end
	}
	
	private function wheelEvent(e:WheelEvent) {
		#if debug
		trace(name + " received mouse wheel scroll");
		#end
	}
	
	private function keyPressEvent(e:KeyEvent) {
		#if debug
		trace(name + " received key press");
		#end
	}
	
	private function keyReleaseEvent(e:KeyEvent) {
		#if debug
		trace(name + " received key release");
		#end
	}
	
	private function keyboardFocusInEvent(e:KeyboardFocusEvent) {
		#if debug
		trace(name + " gained keyboard focus");
		#end
	}
	
	private function keyboardFocusOutEvent(e:KeyboardFocusEvent) {
		#if debug
		trace(name + " lost keyboard focus");
		#end
	}
	
	private function gamepadFocusInEvent(e:GamepadFocusEvent) {
		#if debug
		trace(name + " gained gamepad focus");
		#end
	}
	
	private function gamepadFocusOutEvent(e:GamepadFocusEvent) {
		#if debug
		trace(name + " lost gamepad focus");
		#end
	}
	
	private function hoverEnterEvent(e:HoverEvent) {
		#if debug
		trace(name + " was hovered");
		#end
	}
	
	private function hoverLeaveEvent(e:HoverEvent) {
		#if debug
		trace(name + " was unhovered");
		#end
	}
	
	private function moveEvent(e:MoveEvent) {
		#if debug
		trace(name + " was moved");
		#end
	}
	
	private function resizeEvent(e:ResizeEvent) {
		#if debug
		trace(name + " was resized");
		#end
	}
	
	private function closeEvent(e:CloseEvent) {
		#if debug
		trace(name + " will close");
		#end
	}
		
	private function dragEnterEvent(e:DragEnterEvent) {
		#if debug
		trace(name + " got drag enter");
		#end	
	}
	
	private function dragLeaveEvent(e:DragLeaveEvent) {
		#if debug
		trace(name + " drag leave");
		#end
	}
	
	private function dropEvent(e:DropEvent) {
		#if debug
		trace(name + " received drop");
		#end
	}
	
	private function showEvent(e:ShowEvent) {
		#if debug
		trace(name + " was shown");
		#end
	}
	
	private function hideEvent(e:HideEvent) {
		#if debug
		trace(name + " was hidden");
		#end
	}
	
	private function localeChangeEvent(e:LocaleChangeEvent) {
		#if debug
		trace(name + " received a locale change event");
		#end
	}
	
	private function propertyChangeEvent(e:PropertyChangeEvent) {
		#if debug
		trace(name + " had a property change");
		#end
	}
	
	private function layoutRequestEvent(e:UIEvent) {
		#if debug
		trace(name + " got a layout request");
		#end
		
		//if (e.type == Type.LayoutRequest) {
			// The top level object (or its layout if it has one) recalculates geometry for all dirty children
			// The layout recursively proceeds down the object tree to determine the constraints for each item until it reaches the dirty layout.
			// It produces a final size constraint for the whole layout, which may change the size of the parent widget
			
			// TODO
		//}
	}
				
	private function gamepadAxisMoveEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad axis event");
		#end
	}
	
	private function gamepadButtonDownEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad button down event");
		#end
	}
	
	private function gamepadButtonUpEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad button up event");
		#end
	}
	
	private function gamepadConnectEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad connect event");
		#end
	}
	
	private function gamepadDisconnectEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad disconnect event");
		#end
	}
	
	// Returns the widget furthest down the object hierarchy with the point within it, or null if the point is inside none of them.
	public static function getAt(w:Widget, point:FlxPoint):Widget {
		Sure.sure(w != null);
		Sure.sure(point != null);
		
		if (!isPointOver(w, point)) {
			return null;
		}
		
		while (true) {
			var child = childAt(w, point);
			
			if (child == null) {
				break;
			}
			
			w = child;
		}
		
		return w;
	}
	
	// Returns the first immediate child of the widget that intersects with point, null if there is no intersection
	private static function childAt(w:Widget, point:FlxPoint):Widget {
		Sure.sure(w != null);
		Sure.sure(point != null);
		
		if (w.children == null) {
			return null;
		}
		
		for (child in w.children) {
			if (child.isWidgetType) {
				var childWidget:Widget = cast child;
				
				if (isPointOver(w, point)) {
					return childWidget;
				}
			}
		}
		
		return null;
	}
	
	private static function isPointOver(w:Widget, point:FlxPoint):Bool {
		return w.borderRect().containsFlxPoint(point);
	}
	
	override private function get_isWidgetType():Bool {
		return true;
	}
	
	// TODO this is ugly, consider attaching layouts to blank widgets rather than having an isWidgetType at all?
	private function set_x(x:Int):Int {		
		for (child in children) {
			if (child.isWidgetType) {
				var w:Widget = cast child;
				w.x += (this.x - x);
			}
		}
		
		return this.x = x;
	}
	
	private function set_y(y:Int):Int {		
		for (child in children) {
			if (child.isWidgetType) {
				var w:Widget = cast child;
				w.y += (this.y - y);
			}
		}
		
		return this.y = y;
	}
}