package lycan.ui.core ;

import flixel.math.FlxPoint;
import lycan.ui.events.UIEvent;
import lycan.ui.events.UIEvent.PointerEvent;
import lycan.ui.events.UIEventLoop;
import lycan.ui.pointer.MouseButton;
import lycan.ui.UIObject;
import lycan.ui.widgets.Widget;
import openfl.events.AccelerometerEvent;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.Lib;

#if next
import lime.ui.Gamepad;
#end

#if flash
import flixel.FlxG;
#end

// Interface for translation of platform events into UI events and dispatching them
interface IApplicationRoot {
	var topLevelWidget(get, set):Widget;
	
	var hoveredWidget(default, set):Widget;
	var keyboardFocusWidget(default, set):Widget;
	var gamepadFocusWidget(default, set):Widget;
}

// Responsible for translating OpenFL/platform events into UI events and dispatching them
class UIApplicationRoot {
	private var eventLoop:UIEventLoop;
	private var gestureRecognizers:Array<GestureRecognizer> = new Array<GestureRecognizer>();
	private var listenersAttached:Bool = false;
	
	// Assumes there can only be one top level widget active at any one time
	// TODO a solution to this is probably to use a stack/priority queue of TLWs - only one gets updated at a time, but multiple ones can still be active and rendering
	@:isVar public var topLevelWidget(get, set):Widget = null;
	
	// The widget currently hovered by a pointer device, updated as events spontaneously arrive. Null if no widget is hovered.
	// Note that since this is updated spontaneously by events, it may have a stale reference if an event nulling it out does not arrive for whatever reason.
	// TODO this gets screwed if you resize the window on Flash and move the mouse about - probably a mouse coordinate problem
	private var hoveredWidget(default, set):Widget = null;
	
	// TODO to be complete this needs to work with several conditions: keyboard shortcuts, mouse wheel
	private var keyboardFocusWidget(default, set):Widget = null;
	private var gamepadFocusWidget(default, set):Widget = null;
	
	public function new() {
		eventLoop = new UIEventLoop(this);
	}
	
	/*
	// Returns the next selectable widget in the direction given
	private function getNextSelectableForDirection(direction:Direction, wrapAround:Bool = true):Widget {
		// TODO either iterate over the entire widget tree or pass the root object in? e.g. specifying a list widget will cause it to search only in the list items
		// Should be useful for gamepads
		// TODO could delegate this to layouts?
		return null;
	}
	*/
	
	public function enable() {
		if (!listenersAttached) {
			addEventListeners();
		}
	}
	
	public function disable() {
		if (listenersAttached) {
			removeEventListeners();
		}
	}
	
	public function destroy() {
		hoveredWidget = null;
		keyboardFocusWidget = null;
		gamepadFocusWidget = null;
		eventLoop = null;
		topLevelWidget = null;
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
		if (keyboardFocusWidget != null) {
			var evt = new KeyEvent(EventType.KeyPress);
			evt.charCode = e.charCode;
			evt.keyCode = e.keyCode;
			postEvent(keyboardFocusWidget, evt);
		}
	}
	
	private function onKeyUp(e:KeyboardEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Key up");
		if (keyboardFocusWidget != null) {
			var evt = new KeyEvent(EventType.KeyRelease);
			evt.charCode = e.charCode;
			evt.keyCode = e.keyCode;
			postEvent(keyboardFocusWidget, evt);
		}
	}
	
	private function onMouseWheel(e:MouseEvent) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse wheel");
		
		// TODO may prefer to do this for the first scrollable item, or the focus widget instead
		hoveredWidget = Widget.getAt(topLevelWidget, FlxPoint.get(e.localX, e.localY));
		
		if (hoveredWidget != null) {
			postEvent(hoveredWidget, new WheelEvent(e.delta));
		}
	}
	
	private function onMouseLeave(e:Event) {
		Sure.sure(topLevelWidget != null);
		trace("Mouse leave");
		
		hoveredWidget = null;
	}
	
	private function onMouseDown(e:MouseEvent) {
		flixelScaleModeMouseHack(e);
		
		handlePointerDown(e.localX, e.localY, e.buttonDown);
	}
	
	private function onMouseMove(e:MouseEvent) {
		flixelScaleModeMouseHack(e);
		
		handlePointerMove(e.localX, e.localY, e.buttonDown);
	}
	
	private function onMouseUp(e:MouseEvent) {
		flixelScaleModeMouseHack(e);
		
		handlePointerUp(e.localX, e.localY, e.buttonDown);
	}
	
	private function onTouchBegin(e:TouchEvent) {
		flixelScaleModeTouchHack(e);
		
		handlePointerDown(e.localX, e.localY, true);
	}
	
	private function onTouchMove(e:TouchEvent) {
		flixelScaleModeTouchHack(e);
		
		handlePointerMove(e.localX, e.localY, true);
	}
	
	private function onTouchEnd(e:TouchEvent) {
		flixelScaleModeTouchHack(e);
		
		handlePointerUp(e.localX, e.localY, true);
	}
	
	// NOTE flixel has it's own game scale mode, and it seems necessary to take that into account to get the right game coords
	// TODO check this, but it doesn't seem to be required for non-Flash targets?
	// TODO there's an extra offset on the left side of the window that's missed here?
	private inline function flixelScaleModeMouseHack(e:MouseEvent):Void {
		#if flash
		e.localX /= FlxG.scaleMode.scale.x;
		e.localY /= FlxG.scaleMode.scale.y;
		#end
	}
	
	private inline function flixelScaleModeTouchHack(e:TouchEvent):Void {
		#if flash
		e.localX /= FlxG.scaleMode.scale.x;
		e.localY /= FlxG.scaleMode.scale.y;
		#end
	}
	
	private function handlePointerDown(x:Float, y:Float, down:Bool) {
		Sure.sure(topLevelWidget != null);
		//trace("Pointer down");
		
		var pointerWidget = Widget.getAt(topLevelWidget, FlxPoint.get(x, y));
		hoveredWidget = pointerWidget;
		
		if (hoveredWidget != null) {
			if (hoveredWidget.pointerTrackingPolicy == PointerTrackingPolicy.EnterExit || hoveredWidget.pointerTrackingPolicy == PointerTrackingPolicy.StrongTracking) {
				// TODO down isn't the same as LEFT/RIGHT, fix this
				postEvent(hoveredWidget, makePointerEvent(x, y, down, EventType.PointerPress, hoveredWidget, down ? MouseButton.LEFT : MouseButton.RIGHT));
			}
		}
		
		if (keyboardFocusWidget != pointerWidget) {
			if (pointerWidget != null) {
				if(pointerWidget.keyboardFocusPolicy == KeyboardFocusPolicy.ClickFocus || pointerWidget.keyboardFocusPolicy == KeyboardFocusPolicy.StrongFocus) {
					trace("Offered keyboard focus");
					keyboardFocusWidget = pointerWidget;
					postEvent(keyboardFocusWidget, new KeyboardFocusEvent(EventType.KeyboardFocusIn));
				} else {
					if(keyboardFocusWidget != null) {
						trace("Retracted keyboard focus");
						keyboardFocusWidget = null;
					}
				}
			} else {
				keyboardFocusWidget = null;
			}
		}
	}
	
	private function handlePointerMove(x:Float, y:Float, down:Bool) {
		Sure.sure(topLevelWidget != null);
		//trace("Pointer move");
		
		hoveredWidget = Widget.getAt(topLevelWidget, FlxPoint.get(x, y));
		
		if (hoveredWidget != null) {
			if(hoveredWidget.pointerTrackingPolicy == PointerTrackingPolicy.StrongTracking) {
				postEvent(hoveredWidget, makePointerEvent(x, y, down, EventType.PointerMove, hoveredWidget, down ? MouseButton.LEFT : MouseButton.RIGHT));
				
				if (down) {
					postEvent(hoveredWidget, new DragMoveEvent(EventType.DragMove));
				}
			}
		}
	}
	
	private function handlePointerUp(x:Float, y:Float, down:Bool) {
		Sure.sure(topLevelWidget != null);
		//trace("Pointer up");
		
		hoveredWidget = Widget.getAt(topLevelWidget, FlxPoint.get(x, y));
		
		if (hoveredWidget != null) {
			if(hoveredWidget.pointerTrackingPolicy == PointerTrackingPolicy.EnterExit || hoveredWidget.pointerTrackingPolicy == PointerTrackingPolicy.StrongTracking) {
				postEvent(hoveredWidget, makePointerEvent(x, y, down, EventType.PointerRelease, hoveredWidget, down ? MouseButton.LEFT : MouseButton.RIGHT));
			}
		}
	}
	
	private inline function makePointerEvent(x:Float, y:Float, down:Bool, type:EventType, pointerWidget:Widget, trigger:MouseButton):PointerEvent {
		var event:PointerEvent = new PointerEvent(type);
		event.globalX = x;
		event.globalY = y;
		event.localX = x - pointerWidget.x; // TODO should we use the outer margin or the x coordinate of the widget?
		event.localY = y - pointerWidget.y;
		event.button = trigger;
		
		return event;
	}
	
	private function onGamepadButtonDown(gamepad, button) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad button down");
		// TODO do per-player gamepad ownership, pass player index down to widgets
		// TODO add methods to set the gamepad focus widget
		
		if(gamepadFocusWidget != null) {
			postEvent(gamepadFocusWidget, new GamepadEvent(EventType.GamepadButtonDown));
		}
	}
	
	private function onGamepadButtonUp(gamepad, button) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad button up");
		
		if(gamepadFocusWidget != null) {
			postEvent(gamepadFocusWidget, new GamepadEvent(EventType.GamepadButtonUp));
		}
	}
	
	private function onGamepadConnect(gamepad) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad connect");
		
		if(gamepadFocusWidget != null) {
			postEvent(gamepadFocusWidget, new GamepadEvent(EventType.GamepadConnect));
		}
	}
	
	private function onGamepadDisconnect(gamepad) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad disconnect");
		
		if(gamepadFocusWidget != null) {
			postEvent(gamepadFocusWidget, new GamepadEvent(EventType.GamepadDisconnect));
		}
	}
	
	private function onGamepadAxisMove(gamepad, axis, value:Float) {
		Sure.sure(topLevelWidget != null);
		trace("Gamepad axis move");
		
		if(gamepadFocusWidget != null) {
			postEvent(gamepadFocusWidget, new GamepadEvent(EventType.GamepadAxisMove));
		}
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
		
		// NOTE requires -Dnext
		#if next
		Gamepad.onConnect.add(function(gamepad:Gamepad) {
			trace("Connected gamepad: " + gamepad.name);
			gamepad.onAxisMove.add(onGamepadAxisMove.bind(gamepad));
			gamepad.onButtonDown.add(onGamepadButtonDown.bind(gamepad));
			gamepad.onButtonUp.add(onGamepadButtonUp.bind(gamepad));
			gamepad.onDisconnect.add(onGamepadDisconnect.bind(gamepad));
		});
		#end
		
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
		
		#if next
		// TODO disable gamepads
		//Lib.application.window.onGamepadAxisMove.remove(onGamepadAxisMove);
		//Lib.application.window.onGamepadButtonDown.remove(onGamepadButtonDown);
		//Lib.application.window.onGamepadButtonUp.remove(onGamepadButtonUp);
		//Lib.application.window.onGamepadConnect.remove(onGamepadConnect);
		//Lib.application.window.onGamepadDisconnect.remove(onGamepadDisconnect);
		#end
		
		listenersAttached = false;
	}
	
	// Puts event onto the event loop, to be processed on the next frame
	private function postEvent(receiver:UIObject, event:UIEvent) {
		Sure.sure(receiver != null && event != null);       
		eventLoop.add(receiver, event);
	}
	
	// Sends event directly to receiver, bypassing the event loop
	private static function sendEvent(receiver:UIObject, event:UIEvent):Bool {
		Sure.sure(receiver != null && event != null);
		
		// TODO should we send these even if the receiver is disabled?
		return receiver.event(event);
	}
	
	private function notify(receiver:UIObject, event:UIEvent) {
		Sure.sure(receiver != null);
		Sure.sure(event != null);
		Sure.sure(topLevelWidget != null);
		
		// TODO should we send these even if the receiver is disabled?
		receiver.event(event);
		
		// TODO see http://code.woboq.org/qt5/qtbase/src/widgets/kernel/qapplication.cpp.html notify (this is gonna take awhile.......)
	}
}