package lycan.ui.widgets;

import lycan.ui.UIObject;
import lycan.ui.events.UIEvent;
import lycan.ui.events.UIEvent.ChildEvent;
import lycan.ui.events.UIEvent.DragMoveEvent;
import lycan.ui.events.UIEvent.KeyEvent;
import lycan.ui.events.UIEvent.PointerEvent;
import lycan.ui.events.UIEvent.WheelEvent;
import lycan.ui.pointer.MouseButton;
import lycan.ui.widgets.Widget.PointerTrackingPolicy;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import openfl.ui.Keyboard;
import lycan.ui.widgets.Widget.KeyboardFocusPolicy;

class ListView extends Widget {
	public var signal_currentItemChanged = new Signal2<Widget, Widget>();
	public var signal_itemActivated = new Signal1<Widget>();
	public var signal_itemPressed = new Signal1<Widget>();
	public var signal_itemHovered = new Signal1<Widget>();

	public var wheelEventDeltaMultiplier:Float;
	public var keyboardDeltaMultiplier:Float;
	public var pointerDeltaMultiplier:Float;

	public var lastPressY:Float;

	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
		wheelEventDeltaMultiplier = 10.0;
		keyboardDeltaMultiplier = 30.0;
		pointerDeltaMultiplier = 1.0;

		receiveChildEvents = true;

		lastPressY = y;
		pointerTrackingPolicy = PointerTrackingPolicy.StrongTracking;
		keyboardFocusPolicy = KeyboardFocusPolicy.ClickFocus;
	}

	override private function wheelEvent(e:WheelEvent) {
		super.wheelEvent(e);

		moveChildren(e.delta * wheelEventDeltaMultiplier);

		return false;
	}

	override private function pointerPressEvent(e:PointerEvent) {
		super.pointerPressEvent(e);

		lastPressY = e.globalY;

		return false;
	}

	override private function pointerMoveEvent(e:PointerEvent) {
		super.pointerMoveEvent(e);

		// TODO handle touches, modify pointer events to include the finger id(?)

		if (e.button != MouseButton.LEFT) {
			return false;
		}

		var dy:Float = e.globalY - lastPressY;
		lastPressY = e.globalY;

		moveChildren(dy * pointerDeltaMultiplier);

		return false;
	}

	override private function keyPressEvent(e:KeyEvent) {
		// TODO use this for focusing child items/gamepad control...

		if (e.keyCode == Keyboard.DOWN) {
			moveChildren(-keyboardDeltaMultiplier);
		} else if (e.keyCode == Keyboard.UP) {
			moveChildren(keyboardDeltaMultiplier);
		}

		return false;
	}

	override private function keyReleaseEvent(e:KeyEvent) {
		return false;
	}

	override private function childAddedEvent(e:ChildEvent) {
		super.childAddedEvent(e);

		var child:Widget = cast e.child;
		child.pointerTrackingPolicy = PointerTrackingPolicy.StrongTracking;

		return true;
	}

	override private function childRemovedEvent(e:ChildEvent) {
		super.childRemovedEvent(e);

		return true;
	}

	private function moveChildren(delta:Float):Void {
		for (child in children) {
			if (child.isWidgetType) {
				var w:Widget = cast child;
				w.y += Std.int(delta);
			}
		}
	}
}