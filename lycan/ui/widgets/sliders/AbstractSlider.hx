package lycan.ui.widgets.sliders ;

import lycan.ui.events.UIEvent.HoverEvent;
import lycan.ui.events.UIEvent.KeyEvent;
import lycan.ui.events.UIEvent.PointerEvent;
import lycan.ui.events.UIEvent.WheelEvent;
import lycan.ui.widgets.Widget.PointerTrackingPolicy;
import msignal.Signal.Signal0;
import msignal.Signal.Signal1;

// Base class for sliders. Has no graphical representation though, use a subclass
class AbstractSlider extends Widget {
	public var signal_valueChanged(default,null) = new Signal1<Float>();
	public var signal_sliderPressed(default,null) = new Signal0();
	public var signal_sliderMoved(default,null) = new Signal0();
	public var signal_sliderReleased(default,null) = new Signal0();

	private var minimum:Float;
	private var maximum:Float;
	public var value(default, set):Float;

	public function new(min:Float, max:Float, value:Float, ?parent:UIObject, ?name:String) {
		super(parent, name);

		pointerTrackingPolicy = PointerTrackingPolicy.StrongTracking;

		this.minimum = min;
		this.maximum = max;
		this.value = value;
	}

	override private function wheelEvent(e:WheelEvent) {
		return super.wheelEvent(e);
		// scroll value
	}

	override private function keyPressEvent(e:KeyEvent) {
		return super.keyPressEvent(e);
		// scroll value
	}

	override private function pointerPressEvent(e:PointerEvent) {
		super.pointerPressEvent(e);

		pressed = true;

		value = maximum * e.localX / width;

		signal_sliderPressed.dispatch();

		return true;
	}

	override private function pointerReleaseEvent(e:PointerEvent) {
		super.pointerReleaseEvent(e);

		pressed = false;

		value = maximum * e.localX / width;

		signal_sliderReleased.dispatch();

		return true;
	}

	override private function pointerMoveEvent(e:PointerEvent) {
		super.pointerMoveEvent(e);

		if (pressed) {
			value = maximum * e.localX / width;
		}

		signal_sliderMoved.dispatch();

		return true;
	}

	override private function hoverEnterEvent(e:HoverEvent) {
		return super.hoverEnterEvent(e);

		// TODO if left mouse or touch is already pressed down on entering, then set pressed to true
	}

	override private function hoverLeaveEvent(e:HoverEvent) {
		return  super.hoverLeaveEvent(e);
	}

	private function calculateValue(e:PointerEvent):Float {
		return value; // TODO calculate the % the pointer is across the widget
	}

	private function set_value(v:Float):Float {
		v = Math.max(v, minimum);
		v = Math.min(v, maximum);
		this.value = v;
		signal_valueChanged.dispatch(v);
		return v;
	}
}