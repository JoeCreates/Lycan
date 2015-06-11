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
import openfl.events.FocusEvent;

import openfl.Lib;

// Responsible for translating OpenFL/platform events into UI events and dispatching them to the widgets in the application
class UIApplicationRoot {
	private var eventLoop:UIEventLoop;
	private var listenersAttached:Bool = false;
	
	// The widget currently hovered by a pointer device, updated as events spontaneously arrive. Null if no widget is hovered.
	// Note that since this is updated spontaneously by events, it may have a stale reference if an event nulling it out does not arrive for whatever reason.
	
	// TODO this gets screwed if you resize the window on Flash and move the mouse about - probably a mouse coordinate problem
	private var hoveredWidget(default, set):Widget = null;
	
	// Assumes there can only be one top level widget active at any one time
	// TODO a solution to this is probably to use a stack/priority queue of TLWs
	@:isVar public var topLevelWidget(get, set):Widget = null;
	
	public function new() {
		eventLoop = new UIEventLoop(this);
	}
	
	public function destroy() {
		topLevelWidget = null;
		eventLoop = null;
	}
	
	private function onActivate(e:Event) {
		Sure.sure(topLevelWidget != null);
		trace("UI activated");
	}
	
	private function onDeactivate(e:Event) {
		Sure.sure(topLevelWidget != null);
		trace("UI deactivated");
		
		hoveredWidget = null;
	}
	
	private function onEnterFrame(e:Event) {
		if(topLevelWidget != null) { // TODO need better way of knowing when not to process events
			//trace("Frame entered");
			eventLoop.process();
		}
	}
	
	private function onFocusIn(e:FocusEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Window focused in");
	}
	
	private function onFocusOut(e:FocusEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Window focused out");
		
		hoveredWidget = null;
	}
	
	private function onResize(e:Event) {
		Sure.sure(topLevelWidget != null);
		trace("TLW resized");
		// TODO make the current topLevelWidget resize itself accordingly (possibly rate-limit this to avoid it doing it hundreds of times during the resize)
		
		// TODO only if the TLW should resize rather than ignoring and letting flixel do the scaling or whatever?
		// sendEvent(topLevelWidget, new ResizeEvent());
		
		hoveredWidget = null;
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
		
		hoveredWidget = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerPress));
		}
	}
	
	private function onMouseWheel(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse wheel");
		
		// TODO may prefer to do this for the first scrollable item, or the focus widget instead
		hoveredWidget = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new WheelEvent(EventType.WheelScroll));
		}
	}
	
	private function onMouseMove(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		// trace("Mouse move");
		
		hoveredWidget = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		// TODO possibly rate-limit this to avoid lag, only use if the widget has a mousetracker flag, and cache the last hovered widget
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerMove));
		}
	}
	
	private function onMouseUp(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse up");
		
		hoveredWidget = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerRelease));
		}
	}
	
	private function onMouseLeave(e:Event) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse leave");
		
		hoveredWidget = null;
	}
	
	private function onTouchBegin(e:TouchEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Touch begin");
		
		hoveredWidget = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerPress));
		}
	}
	
	private function onTouchMove(e:TouchEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Touch move");
		
		hoveredWidget = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerMove));
		}
	}
	
	private function onTouchEnd(e:TouchEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Touch end");
		
		hoveredWidget = Widget.findHoveredWidget(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerRelease));
		}
	}
	
	// TODO
	private function onGamepadButtonDown(gamepad, button) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad button down");
		
		// TODO work out a gamepad focus system, or give the user control over it manually?
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
	
	private function set_hoveredWidget(w:Widget):Widget {
		#if debug
		if (w == null) {
			trace("Set hovered widget to null");
		} else {
			if(w.name == null) {
				trace("Set hovered widget to " + Type.getClassName(Type.getClass(w)));
			} else {
				trace("Set hovered widget to " + w.name);
			}
		}
		#end
		
		return hoveredWidget = w;
	}
	
	private function set_topLevelWidget(nextTopLevelWidget:Widget):Widget {
		#if debug
		trace("Set top level widget to: " + nextTopLevelWidget.name);
		#end
		
		if (nextTopLevelWidget == null) {
			Sure.sure(listenersAttached);
			removeEventListeners();
		}
		
		if (nextTopLevelWidget != null && this.topLevelWidget != nextTopLevelWidget && !listenersAttached) {
			addEventListeners();
		}
		
		eventLoop.clear();
		
		hoveredWidget = null;
		
		return this.topLevelWidget = nextTopLevelWidget;
	}
	
	private function addEventListeners() {
		Sure.sure(Lib.current.stage != null);
		
		// TODO it would be faster to loop through the whole OpenFL event loop itself, possibly
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		Lib.current.stage.addEventListener(Event.ACTIVATE, onActivate);
		Lib.current.stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		Lib.current.stage.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		Lib.current.stage.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		//Lib.current.stage.addEventListener(MouseEvent.RELEASE_OUTSIDE, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		Lib.current.stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave); // TODO may not work on Windows native build
		
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		
		#if !neko // Crashes
		Lib.current.stage.addEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
		#end
		
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
		
		// TODO requires more recent openfl mode than haxeflixel can use (seeing openfl._legacy.Lib errors)?
		//Sure.sure(Lib.application.window != null);
		//Lib.application.window.onGamepadAxisMove.add(onGamepadAxisMove);
		//Lib.application.window.onGamepadButtonDown.add(onGamepadButtonDown);
		//Lib.application.window.onGamepadButtonUp.add(onGamepadButtonUp);
		//Lib.application.window.onGamepadConnect.add(onGamepadConnect);
		//Lib.application.window.onGamepadDisconnect.add(onGamepadDisconnect);
		
		listenersAttached = true;
	}
	
	private function removeEventListeners() {		
		Sure.sure(Lib.current.stage != null);
		
		// TODO possible to just clear all for this object? // Pass a list of methods/events
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		Lib.current.stage.removeEventListener(Event.ACTIVATE, onActivate);
		Lib.current.stage.removeEventListener(Event.DEACTIVATE, onDeactivate);
		Lib.current.stage.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		Lib.current.stage.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		//Lib.current.stage.removeEventListener(MouseEvent.RELEASE_OUTSIDE, onMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseDown);
		Lib.current.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
		Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		Lib.current.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
		
		Lib.current.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		Lib.current.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		Lib.current.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		
		#if !neko // Crashes
		Lib.current.stage.removeEventListener(AccelerometerEvent.UPDATE, onAccelerometerUpdate);
		#end
		
		Lib.current.stage.removeEventListener(Event.RESIZE, onResize);
		
		//Sure.sure(Lib.application.window != null);
		//Lib.application.window.onGamepadAxisMove.remove(onGamepadAxisMove);
		//Lib.application.window.onGamepadButtonDown.remove(onGamepadButtonDown);
		//Lib.application.window.onGamepadButtonUp.remove(onGamepadButtonUp);
		//Lib.application.window.onGamepadConnect.remove(onGamepadConnect);
		//Lib.application.window.onGamepadDisconnect.remove(onGamepadDisconnect);
		
		listenersAttached = false;
	}
}