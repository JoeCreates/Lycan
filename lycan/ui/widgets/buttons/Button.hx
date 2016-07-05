package lycan.ui.widgets.buttons ;

import lycan.ui.events.UIEvent.HoverEvent;
import lycan.ui.events.UIEvent.PointerEvent;
import lycan.ui.UIObject;
import msignal.Signal.Signal0;

// Base class
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
		return true;
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
		return true;
	}

	override function hoverEnterEvent(e:HoverEvent) {
		super.hoverEnterEvent(e);
		signal_hovered.dispatch();
		return true;
	}

	override function hoverLeaveEvent(e:HoverEvent) {
		super.hoverLeaveEvent(e);
		signal_unhovered.dispatch();
		return true;
	}

	override private function set_width(width:Int):Int {
		super.set_width(width);
		centerButtonGraphics();
		return width;
	}

	override private function set_height(height:Int):Int {
		super.set_height(height);
		centerButtonGraphics();
		return height;
	}

	private function centerButtonGraphics():Void {
		for (graphic in graphics) {
			graphic.x = x +  cast ((width - graphic.width) / 2);
			graphic.y = y + cast ((height - graphic.height) / 2);
		}
	}
}