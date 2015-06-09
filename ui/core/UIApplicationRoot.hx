package lycan.ui.core ;

import flixel.math.FlxPoint;
import lycan.ui.events.UIEvent;
import lycan.ui.events.UIEventLoop;
import lycan.ui.widgets.Widget;

// TODO this is mostly the openfl -> UI event dispatcher stuff, it will need to hook into the OpenFL/HaxeFlixel event loop and other event sources to translate a bunch of these things into UIEvents
class UIApplicationRoot {
	private var eventLoop:UIEventLoop;
	public var topLevelWidget(null,set):Widget = null; // Assumes there can only be one top level widget active at any one time
	
	public function new() {
		eventLoop = new UIEventLoop(this);
	}
	
	public function notify(receiver:UIObject, event:UIEvent) {
		Sure.sure(receiver != null && event != null);
		
		if (topLevelWidget == null) {
			return;
		}
		
		// see http://code.woboq.org/qt5/qtbase/src/widgets/kernel/qapplication.cpp.html notify (this is gonna take awhile.......)
	}
	
	private function sendPointerEvent(receiver:Widget, event:PointerEvent, lastReceiver:Widget) {
		//var widgetUnderMouse:Bool = receiver.rect().contains(event.localPosition());
	}
	
	private function dispatchEnterLeave(enter:Widget, leave:Widget, globalPosition:FlxPoint) {
		if (enter != null) {
			postEvent(enter, new UIEvent(Type.Enter)); // TODO pass new global mouse position
		}
		if (leave != null) {
			postEvent(leave, new UIEvent(Type.Leave));
		}
	}
	
	private function postEvent(receiver:UIObject, event:UIEvent) {
		Sure.sure(receiver != null && event != null);
		eventLoop.add(receiver, event);
	}
	
	public function set_topLevelWidget(topLevelWidget:Widget):Widget {
		#if debug
		trace("Set top level widget to: " + topLevelWidget.name);
		#end
		
		eventLoop.clear();
		
		return this.topLevelWidget = topLevelWidget;
	}
}