package lycan.ui.core ;

import flixel.math.FlxPoint;
import lycan.ui.events.UIEvent;
import lycan.ui.events.UIEvent.PointerEvent;
import lycan.ui.events.UIEventLoop;
import lycan.ui.UIObject;
import lycan.ui.widgets.Widget;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.events.AccelerometerEvent;
import openfl.Lib;

// Responsible for translating OpenFL/platform events into UI events and dispatching them to the widgets in the application
@:allow(DebugRenderer)
class UIApplicationRoot {
	private var eventLoop:UIEventLoop;
	
	// Assumes there can only be one top level widget active at any one time
	// TODO a solution to this is probably to use a stack/priority queue of TLWs
	@:isVar public var topLevelWidget(get, set):Widget = null;
	
	public function new() {
		eventLoop = new UIEventLoop(this);
		
		Sure.sure(Lib.current.stage != null);
		
		// TODO it would be faster to loop through the whole OpenFL event loop itself, possibly
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		Lib.current.stage.addEventListener(Event.ACTIVATE, onActivate);
		Lib.current.stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		
		Lib.current.stage.addEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
		
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
		
		// TODO requires more recent openfl mode than haxeflixel can use (seeing openfl._legacy.Lib errors)?
		//Sure.sure(Lib.application.window != null);
		//Lib.application.window.onGamepadAxisMove.add(onGamepadAxisMove);
		//Lib.application.window.onGamepadButtonDown.add(onGamepadButtonDown);
		//Lib.application.window.onGamepadButtonUp.add(onGamepadButtonUp);
		//Lib.application.window.onGamepadConnect.add(onGamepadConnect);
		//Lib.application.window.onGamepadDisconnect.add(onGamepadDisconnect);
	}
	
	// TODO call this if the TLW is set to null?
	public function destroy() {
		// TODO destroy event loop?
		
		Sure.sure(Lib.current.stage != null);
		
		// TODO possible to just clear all for this object?
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		Lib.current.stage.removeEventListener(Event.ACTIVATE, onActivate);
		Lib.current.stage.removeEventListener(Event.DEACTIVATE, onDeactivate);
		
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseDown);
		Lib.current.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
		Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		
		Lib.current.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		Lib.current.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		Lib.current.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		
		Lib.current.stage.removeEventListener(Event.RESIZE, onResize);
		
		//Sure.sure(Lib.application.window != null);
		//Lib.application.window.onGamepadAxisMove.remove(onGamepadAxisMove);
		//Lib.application.window.onGamepadButtonDown.remove(onGamepadButtonDown);
		//Lib.application.window.onGamepadButtonUp.remove(onGamepadButtonUp);
		//Lib.application.window.onGamepadConnect.remove(onGamepadConnect);
		//Lib.application.window.onGamepadDisconnect.remove(onGamepadDisconnect);
	}
	
	private function onActivate(e:Event) {
		trace("UI activated");
	}
	
	private function onDeactivate(e:Event) {
		trace("UI deactivated");
	}
	
	private function onEnterFrame(e:Event) {
		if(topLevelWidget != null) { // TODO need better way of knowing when not to process events
			//trace("Frame entered");
			
			eventLoop.process();
		}
	}
	
	private function onResize(e:Event) {
		trace("TLW resized");
		// TODO make the current topLevelWidget resize itself accordingly (possibly rate-limit this to avoid it doing it hundreds of times during the resize)
		
		// TODO only if the TLW should resize rather than ignoring and letting flixel do the scaling or whatever?
		// sendEvent(topLevelWidget, new ResizeEvent());
	}
	
	private function onKeyDown(e:KeyboardEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Key down");
		// TODO pass the key event to the appropriate widget
		// TODO maintain a list of focus widgets that can receive the input
	}
	
	private function onKeyUp(e:KeyboardEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Key up");
		// TODO pass the key event to the appropriate widget
	}
	
	private function onMouseDown(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse down");
		
		var w = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (w != null) {
			postEvent(w, new PointerEvent(EventType.PointerPress));
		}
	}
	
	private function onMouseWheel(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse wheel");
		
		// TODO may prefer to do this for the first scrollable item, or the focus widget instead
		var w = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (w != null) {
			postEvent(w, new WheelEvent(EventType.WheelScroll));
		}
	}
	
	private function onMouseMove(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		// trace("Mouse move");
		
		var w = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		// TODO possibly rate-limit this to avoid lag, only use if the widget has a mousetracker flag, and cache the last hovered widget
		if (w != null) {
			postEvent(w, new PointerEvent(EventType.PointerMove));
		}
	}
	
	private function onMouseUp(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse up");
		
		var w = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (w != null) {
			postEvent(w, new PointerEvent(EventType.PointerRelease));
		}
	}
	
	private function onTouchBegin(e:TouchEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Touch begin");
		
		var w = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (w != null) {
			postEvent(w, new PointerEvent(EventType.PointerPress));
		}
	}
	
	private function onTouchMove(e:TouchEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Touch move");
		
		var w = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (w != null) {
			postEvent(w, new PointerEvent(EventType.PointerMove));
		}
	}
	
	private function onTouchEnd(e:TouchEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Touch end");
		
		var w = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (w != null) {
			postEvent(w, new PointerEvent(EventType.PointerRelease));
		}
	}
	
	// TODO
	private function onGamepadButtonDown(gamepad, button) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad button down");
	}
	
	private function onGamepadButtonUp(gamepad, button) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad button up");
	}
	
	private function onGamepadConnect(gamepad) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad connect");
		
	}
	
	private function onGamepadDisconnect(gamepad) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad disconnect");
		
	}
	
	private function onGamepadAxisMove(gamepad, axis, value:Float) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad axis move");
	}
	
	private function onAccelerometerUpdate(e:AccelerometerEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Accelerometer update");
	}
	
	public function notify(receiver:UIObject, event:UIEvent) {
		Sure.sure(receiver != null);
		Sure.sure(event != null);
		Sure.sure(topLevelWidget != null);
		
		receiver.event(event);
		
		// TODO see http://code.woboq.org/qt5/qtbase/src/widgets/kernel/qapplication.cpp.html notify (this is gonna take awhile.......)
	}
	
	private function sendPointerEvent(receiver:Widget, event:PointerEvent, lastReceiver:Widget) {
		//var widgetUnderMouse:Bool = receiver.rect().contains(event.localPosition());
	}
	
	private function dispatchEnterLeave(enter:Widget, leave:Widget, globalPosition:FlxPoint) {
		if (enter != null) {
			postEvent(enter, new UIEvent(EventType.Enter)); // TODO pass new global mouse position
		}
		if (leave != null) {
			postEvent(leave, new UIEvent(EventType.Leave));
		}
	}
	
	// Puts event onto the event loop, to be processed on the next frame
	private function postEvent(receiver:UIObject, event:UIEvent) {
		Sure.sure(receiver != null && event != null);
		eventLoop.add(receiver, event);
	}
	
	// Sends event directly to receiver, bypassing the event loop
	private function sendEvent(receiver:UIObject, event:UIEvent):Bool {
		Sure.sure(receiver != null && event != null);
		return receiver.event(event);
	}
	
	public function get_topLevelWidget():Widget {
		return topLevelWidget;
	}
	
	public function set_topLevelWidget(topLevelWidget:Widget):Widget {
		#if debug
		trace("Set top level widget to: " + topLevelWidget.name);
		#end
		
		eventLoop.clear();
		
		return this.topLevelWidget = topLevelWidget;
	}
}