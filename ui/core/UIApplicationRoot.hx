package lycan.ui.core ;

import flixel.math.FlxPoint;
import lycan.ui.events.UIEvent;
import lycan.ui.events.UIEvent.PointerEvent;
import lycan.ui.events.UIEventLoop;
import lycan.ui.UIObject;
import lycan.ui.widgets.Widget;
import openfl.events.AccelerometerEvent;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.Lib;
import source.lycan.ui.core.GestureRecognizer;

// Interface for translation of platform events into UI events and dispatching them
interface IApplicationRoot {
	var topLevelWidget(get, set):Widget;
	
	var hoveredWidget(default, set):Widget;
	var keyboardFocusWidget(default, set):Widget;
	var gamepadFocusWidget(default, set):Widget;
	
	var keyboardGrabWidget(default, set):Widget;
	var gamepadGrabWidget(default, set):Widget;
}

// Responsible for translating OpenFL/platform events into UI events and dispatching them
class UIApplicationRoot {
	private var eventLoop:UIEventLoop;
	private var gestureRecognizers:Array<GestureRecognizer> = new Array<GestureRecognizer>();
	private var listenersAttached:Bool = false;
	
	// The widget currently hovered by a pointer device, updated as events spontaneously arrive. Null if no widget is hovered.
	// Note that since this is updated spontaneously by events, it may have a stale reference if an event nulling it out does not arrive for whatever reason.
	
	// Assumes there can only be one top level widget active at any one time
	// TODO a solution to this is probably to use a stack/priority queue of TLWs
	@:isVar public var topLevelWidget(get, set):Widget = null;
	
	// TODO this gets screwed if you resize the window on Flash and move the mouse about - probably a mouse coordinate problem
	// TODO need to implement a hover policy, or have a hoverable flag on widgets
	private var hoveredWidget(default, set):Widget = null;
	
	// TODO to be complete this needs to work with several conditions: keyboard shortcuts, mouse wheel
	// TODO require keyboard focus policies to be set on widgets
	private var keyboardFocusWidget(default, set):Widget = null;
	
	// TODO require gamepad focus policies to be set on widgets
	private var gamepadFocusWidget(default, set):Widget = null;
	
	// TODO use these to override the current widget focus
	//private var keyboardGrabWidget(default, set):Widget = null;
	//private var gamepadGrabWidget(default, set):Widget = null;
	
	public function new() {
		eventLoop = new UIEventLoop(this);
	}
	
	public function destroy() {
		topLevelWidget = null;
		eventLoop = null;
	}
	
	private function onAppActivate(e:Event) {
		Sure.sure(topLevelWidget != null);
		trace("UI activated");
	}
	
	private function onAppDeactivate(e:Event) {
		Sure.sure(topLevelWidget != null);
		trace("UI deactivated");
		
		hoveredWidget = null;
	}
	
	private function onEnterFrame(e:Event) {
		//trace("Frame entered");
		
		if(topLevelWidget != null) { // TODO need better way of knowing when not to process events
			eventLoop.process();
		}
	}
	
	private function onAppFocusIn(e:FocusEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Window focused in");
	}
	
	private function onAppFocusOut(e:FocusEvent) {
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
		// TODO maintain a list of focus widgets that can receive the input, process events from widgets that request to gain focus? no need to make keyboard exclusive to 1 widget...
		if (keyboardFocusWidget != null) {
			postEvent(keyboardFocusWidget, new KeyEvent(EventType.KeyPress));
		}
	}
	
	private function onKeyUp(e:KeyboardEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Key up");
		// TODO maintain a list of focus widgets that can receive the input, process events from widgets that request to gain focus? no need to make keyboard exclusive to 1 widget...
		if (keyboardFocusWidget != null) {
			postEvent(keyboardFocusWidget, new KeyEvent(EventType.KeyRelease));
		}
	}
	
	private function onMouseDown(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse down");
		
		var mousedWidget = Widget.getAt(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		hoveredWidget = mousedWidget;
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerPress));
		}
		
		if (keyboardFocusWidget != mousedWidget) {
			if (mousedWidget != null) {
				if(mousedWidget.keyboardFocusPolicy == KeyboardFocusPolicy.ClickFocus || mousedWidget.keyboardFocusPolicy == KeyboardFocusPolicy.StrongFocus) {
					trace("Offered keyboard focus");
					keyboardFocusWidget = mousedWidget;
					postEvent(keyboardFocusWidget, new KeyboardFocusEvent(EventType.KeyboardFocusIn));
				} else {
					trace("Retracted keyboard focus");
					keyboardFocusWidget = null;
				}
			} else {
				keyboardFocusWidget = null;
			}
		}
	}
	
	private function onMouseWheel(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse wheel");
		
		// TODO may prefer to do this for the first scrollable item, or the focus widget instead
		hoveredWidget = Widget.getAt(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new WheelEvent(EventType.WheelScroll));
		}
	}
	
	private function onMouseMove(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		//trace("Mouse move");
		
		hoveredWidget = Widget.getAt(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerMove));
		}
	}
	
	private function onMouseUp(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse up");
		
		hoveredWidget = Widget.getAt(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
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
		
		hoveredWidget = Widget.getAt(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerPress));
		}
	}
	
	private function onTouchMove(e:TouchEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Touch move");
		
		hoveredWidget = Widget.getAt(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerMove));
		}
	}
	
	private function onTouchEnd(e:TouchEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Touch end");
		
		hoveredWidget = Widget.getAt(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new PointerEvent(EventType.PointerRelease));
		}
	}
	
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
	
	private function dispatchPointerEnterLeave(enter:Widget, leave:Widget) {
		if (enter != null) {
			postEvent(enter, new HoverEvent(EventType.HoverEnter));
		}
		if (leave != null) {
			postEvent(leave, new HoverEvent(EventType.HoverLeave));
		}
	}
	
	public function get_topLevelWidget():Widget {
		return topLevelWidget;
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
	
	private function set_hoveredWidget(nextHoveredWidget:Widget):Widget {
		#if debug
		if (nextHoveredWidget == null) {
			trace("Set hovered widget to null");
		} else {
			if (nextHoveredWidget != hoveredWidget) {
				if(nextHoveredWidget.name == null) {
					trace("Set hovered widget to " + Type.getClassName(Type.getClass(nextHoveredWidget)));
				} else {
					trace("Set hovered widget to " + nextHoveredWidget.name);
				}
			}
		}
		#end
		
		if(nextHoveredWidget != hoveredWidget) {
			dispatchPointerEnterLeave(nextHoveredWidget, hoveredWidget);
		}
		
		return hoveredWidget = nextHoveredWidget;
	}
	
	private function set_keyboardFocusWidget(nextKeyboardFocusWidget:Widget):Widget {
		#if debug
		trace("Keyboard focus changed");
		#end
		
		return this.keyboardFocusWidget = nextKeyboardFocusWidget;
	}
	
	private function set_gamepadFocusWidget(nextGamepadFocusWidget:Widget):Widget {
		#if debug
		trace("Gamepad focus changed");
		#end
		
		return this.gamepadFocusWidget = nextGamepadFocusWidget;
	}
	
	public function registerGestureRecognizer(recognizer:GestureRecognizer) {
		gestureRecognizers.push(recognizer);
	}
	
	private function addEventListeners() {
		Sure.sure(Lib.current.stage != null);
		
		// TODO it would be faster to loop through the whole OpenFL event loop itself, possibly
		Lib.current.stage.addEventListener(Event.ACTIVATE, onAppActivate);
		Lib.current.stage.addEventListener(Event.DEACTIVATE, onAppDeactivate);
		Lib.current.stage.addEventListener(FocusEvent.FOCUS_IN, onAppFocusIn);
		Lib.current.stage.addEventListener(FocusEvent.FOCUS_OUT, onAppFocusOut);
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
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
		Lib.current.stage.removeEventListener(Event.ACTIVATE, onAppActivate);
		Lib.current.stage.removeEventListener(Event.DEACTIVATE, onAppDeactivate);
		Lib.current.stage.removeEventListener(FocusEvent.FOCUS_IN, onAppFocusIn);
		Lib.current.stage.removeEventListener(FocusEvent.FOCUS_OUT, onAppFocusOut);
		
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		
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
	
	private function notify(receiver:UIObject, event:UIEvent) {
		Sure.sure(receiver != null);
		Sure.sure(event != null);
		Sure.sure(topLevelWidget != null);
		
		receiver.event(event);
		
		// TODO see http://code.woboq.org/qt5/qtbase/src/widgets/kernel/qapplication.cpp.html notify (this is gonna take awhile.......)
	}
}