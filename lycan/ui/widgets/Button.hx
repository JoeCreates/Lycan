package lycan.ui.widgets ;

import flixel.FlxSprite;
import lycan.ui.renderer.IRenderItem;
import lycan.ui.UIObject;
import msignal.Signal.Signal0;
import msignal.Signal.Signal1;
import lycan.ui.events.UIEvent.HoverEvent;
import lycan.ui.events.UIEvent.PointerEvent;

// Button logic with no graphic
class Button extends Widget {	
	public var signal_pressed = new Signal0();
	public var signal_released = new Signal0();
	public var signal_hovered = new Signal0();
	public var signal_unhovered = new Signal0();
	public var signal_clicked = new Signal0(); // Emitted if the button is pressed down and released whilst within the button area
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
	
	override private function pointerPressEvent(e:PointerEvent) {
		super.pointerPressEvent(e);
		signal_pressed.dispatch();
	}
	
	override function pointerReleaseEvent(e:PointerEvent) {
		if (hovered && pressed) {
			#if debug
			trace(name + " was clicked");
			#end
			
			signal_clicked.dispatch();
		}
		
		super.pointerReleaseEvent(e);
		signal_released.dispatch();
	}
	
	override function hoverEnterEvent(e:HoverEvent) {
		super.hoverEnterEvent(e);
		signal_hovered.dispatch();
	}
	
	override function hoverLeaveEvent(e:HoverEvent) {
		super.hoverLeaveEvent(e);
		signal_unhovered.dispatch();
	}
}