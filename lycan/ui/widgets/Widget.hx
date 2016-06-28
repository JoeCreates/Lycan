package lycan.ui.widgets;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import lycan.ui.events.UIEvent;
import lycan.ui.layouts.Layout;
import lycan.ui.UIObject;

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

enum PointerTrackingPolicy {
	EnterExit;
	StrongTracking;
	NoTracking;
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
	public var graphics = new Array<FlxSprite>();
	public var layout(default,set):Layout = null;
	@:isVar public var x(get, set):Int = 0;
	@:isVar public var y(get, set):Int = 0;
	@:isVar public var width(get, set):Int = 0;
	@:isVar public var height(get, set):Int = 0;
	public var pointerTrackingPolicy:PointerTrackingPolicy = PointerTrackingPolicy.EnterExit;
	public var keyboardFocusPolicy:KeyboardFocusPolicy = KeyboardFocusPolicy.NoFocus;
	public var gamepadFocusPolicy:GamepadFocusPolicy = GamepadFocusPolicy.NoFocus;
	public var minWidth:Int = 0;
	public var minHeight:Int = 0;
	public var maxWidth:Int = 10000;
	public var maxHeight:Int = 10000;
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

	// TODO keep these in subclasses?
	private var hovered(default, set):Bool = false;
	private var pressed(default, set):Bool = false;

	public function new(?parent:UIObject = null, ?name:String) {
		super(parent, name);

		#if debug
		if(name == null) {
			this.name = Type.getClassName(Type.getClass(this));
		}
		#end
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

	public function borderCenter():FlxPoint {
		var borderRect = borderRect();
		return FlxPoint.get(borderRect.x + borderRect.width / 2, borderRect.y + borderRect.height / 2); // TODO avoid FlxPoint and minimize calculation
	}

	public function outerCenter():FlxPoint {
		var outerRect = outerRect();
		return FlxPoint.get(outerRect.x + outerRect.width / 2, outerRect.y + outerRect.height / 2); // TODO avoid FlxPoint and minimize calculation
	}

	public function updateGeometry() {
		// NOTE for now just updating all children directly
		// NOTE ideally this would work in a smart way
		if(layout != null) {
			layout.update();
		}

		for (child in children) {
			if(Std.is(child, Widget)) {
				var w:Widget = cast child;
				w.updateGeometry();
			}
		}
	}

	override public function event(e:UIEvent):Bool {
		if (super.event(e)) {
			return true;
		}

		return switch(e.type) {
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
			case EventType.Gesture:
				gestureEvent(cast e);
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
			case EventType.DragMove:
				dragMoveEvent(cast e);
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
				trace("Unhandled event " + e);
				false;
		}
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

	// TODO Steal ALL pointer input until release
	public function grabPointer() {

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

		pressed = true;
		return false;
	}

	private function pointerReleaseEvent(e:PointerEvent) {
		#if debug
		trace(name + " received pointer release");
		#end

		pressed = false;
		return false;
	}

	private function pointerMoveEvent(e:PointerEvent) {
		#if debug
		//trace(name + " received pointer move");
		#end

		return false;
	}

	private function wheelEvent(e:WheelEvent) {
		#if debug
		trace(name + " received mouse wheel scroll");
		#end

		return false;
	}

	private function keyPressEvent(e:KeyEvent) {
		#if debug
		trace(name + " received key press");
		#end

		return false;
	}

	private function keyReleaseEvent(e:KeyEvent) {
		#if debug
		trace(name + " received key release");
		#end

		return false;
	}

	private function keyboardFocusInEvent(e:KeyboardFocusEvent) {
		#if debug
		trace(name + " gained keyboard focus");
		#end

		return false;
	}

	private function keyboardFocusOutEvent(e:KeyboardFocusEvent) {
		#if debug
		trace(name + " lost keyboard focus");
		#end

		return false;
	}

	private function gamepadFocusInEvent(e:GamepadFocusEvent) {
		#if debug
		trace(name + " gained gamepad focus");
		#end

		return false;
	}

	private function gamepadFocusOutEvent(e:GamepadFocusEvent) {
		#if debug
		trace(name + " lost gamepad focus");
		#end

		return false;
	}

	private function hoverEnterEvent(e:HoverEvent) {
		#if debug
		trace(name + " was hovered");
		#end

		hovered = true;

		return false;
	}

	private function hoverLeaveEvent(e:HoverEvent) {
		#if debug
		trace(name + " was unhovered");
		#end

		pressed = false;
		hovered = false;

		return false;
	}

	private function moveEvent(e:MoveEvent) {
		#if debug
		trace(name + " was moved");
		#end

		return false;
	}

	private function resizeEvent(e:ResizeEvent) {
		#if debug
		trace(name + " was resized");
		#end

		return false;
	}

	private function closeEvent(e:CloseEvent) {
		#if debug
		trace(name + " will close");
		#end

		return false;
	}

	private function dragEnterEvent(e:DragEnterEvent) {
		#if debug
		trace(name + " got drag enter");
		#end

		return false;
	}

	private function dragMoveEvent(e:DragMoveEvent) {
		#if debug
		//trace(name + " got drag move");
		#end

		return false;
	}

	private function dragLeaveEvent(e:DragLeaveEvent) {
		#if debug
		trace(name + " drag leave");
		#end

		return false;
	}

	private function dropEvent(e:DropEvent) {
		#if debug
		trace(name + " received drop");
		#end

		return false;
	}

	private function showEvent(e:ShowEvent) {
		#if debug
		trace(name + " was shown");
		#end

		return false;
	}

	private function hideEvent(e:HideEvent) {
		#if debug
		trace(name + " was hidden");
		#end

		return false;
	}

	private function localeChangeEvent(e:LocaleChangeEvent) {
		#if debug
		trace(name + " received a locale change event");
		#end

		return false;
	}

	private function propertyChangeEvent(e:PropertyChangeEvent) {
		#if debug
		trace(name + " had a property change");
		#end

		return false;
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

		return false;
	}

	private function gamepadAxisMoveEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad axis event");
		#end

		return false;
	}

	private function gamepadButtonDownEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad button down event");
		#end

		return false;
	}

	private function gamepadButtonUpEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad button up event");
		#end

		return false;
	}

	private function gamepadConnectEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad connect event");
		#end

		return false;
	}

	private function gamepadDisconnectEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad disconnect event");
		#end

		return false;
	}

	private function gestureEvent(e:GestureEvent) {
		#if debug
		trace(name + " got a gesture event of type: " + e.type);
		#end

		return false;
	}

	override private function childAddedEvent(e:ChildEvent) {
		#if debug
		trace(name + " got a child added event");
		#end

		if(layout != null) {
			layout.event(e);
		}

		return false;
	}

	override private function childRemovedEvent(e:ChildEvent) {
		#if debug
		trace(name + " got a child removed event");
		#end

		if(layout != null) {
			layout.event(e);
		}

		return false;
	}


	// Returns the widget furthest down the object hierarchy with the point within it, or null if the point is inside none of them.
	public static function getAt(root:Widget, point:FlxPoint):Widget {
		return meetsCondition(root, isPointOver, point);
	}

	// Returns the first immediate child of the widget that intersects with point, null if there is no intersection
	private static function childAt(root:Widget, x:Int, y:Int):Widget {
		var pt = FlxPoint.get(x, y);
		var child = childMeetsCondition(root, isPointOver, pt);
		pt.put();
		return child;
	}

	// Returns the next selectable selectable widget in the direction given
	private function getNextSelectableForDirection(direction:Direction, wrapAround:Bool = true):Widget {
		// TODO either iterate over the entire widget tree or pass the root object in? e.g. specifying a list widget will cause it to search only in the list items
		// Should be useful for gamepads
		// TODO could delegate this to layouts?


		return null;
	}

	// Returns the widget furthest down the object hierarchy which meets the condition, or null if none do.
	private static function meetsCondition<T>(root:Widget, f:Widget->T->Bool, p:T):Widget {
		Sure.sure(root != null);
		Sure.sure(f != null);
		Sure.sure(p != null);

		if (!f(root, p)) {
			return null;
		}

		while (true) {
			var child = childMeetsCondition(root, f, p);

			if (child == null) {
				return root;
			}

			root = child;
		}

		return null;
	}

	private static function childMeetsCondition<T>(root:Widget, f:Widget->T->Bool, p:T):Widget {
		Sure.sure(root != null);
		Sure.sure(f != null);
		Sure.sure(p != null);

		for (child in root.children) {
			if (child.isWidgetType) {
				var childWidget:Widget = cast child;

				if (f(childWidget, p)) {
					return childWidget;
				}
			}
		}

		return null;
	}

	private static function isPointOver(w:Widget, point:FlxPoint):Bool {
		return w.borderRect().containsPoint(point);
	}

	override private function get_isWidgetType():Bool {
		return true;
	}

	private function set_layout(layout:Layout):Layout {
		if (this.layout != null) {
			throw "Don't support changing layouts yet"; // TODO remove the old layout
		}

		layout.owner = this;
		return this.layout = layout;
	}

	private function get_x():Int {
		return x;
	}

	private function set_x(x:Int):Int {
		for (graphic in graphics) {
			graphic.x -= (this.x - x);
		}

		for (child in children) {
			if (child.isWidgetType) {
				var w:Widget = cast child;
				w.x += (this.x - x);
			}
		}

		return this.x = x;
	}

	private function get_y():Int {
		return y;
	}

	private function set_y(y:Int):Int {
		for (graphic in graphics) {
			graphic.y -= (this.y - y);
		}

		for (child in children) {
			if (child.isWidgetType) {
				var w:Widget = cast child;
				w.y += (this.y - y);
			}
		}

		return this.y = y;
	}

	private function get_width():Int {
		return this.width;
	}

	private function get_height():Int {
		return height;
	}

	private function set_width(width:Int):Int {
		return this.width = width;
	}

	private function set_height(height:Int):Int {
		return this.height = height;
	}

	private function set_hovered(hovered:Bool):Bool {
		return this.hovered = hovered;
	}

	private function set_pressed(pressed:Bool):Bool {
		return this.pressed = pressed;
	}
}