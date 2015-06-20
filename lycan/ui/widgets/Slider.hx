package lycan.ui.widgets ;

import msignal.Signal.Signal0;
import msignal.Signal.Signal1;
import lycan.ui.events.UIEvent.WheelEvent;
import lycan.ui.events.UIEvent.KeyEvent;
import lycan.ui.events.UIEvent.PointerEvent;

class Slider extends Widget {
	public var signal_valueChanged(default,null) = new Signal1<Float>();
	public var signal_sliderPressed(default,null) = new Signal0();
	public var signal_sliderMoved(default,null) = new Signal0();
	public var signal_sliderReleased(default,null) = new Signal0();
	
	private var minimum:Float;
	private var maximum:Float;
	private var value(default, set):Float;
	
	public function new(min:Float, max:Float, value:Float, ?parent:UIObject, ?name:String) {
		super(parent, name);
		
		this.minimum = min;
		this.maximum = max;
		this.value = value;
	}
	
	override private function wheelEvent(e:WheelEvent) {
		super.wheelEvent(e);
		// scroll value
	}
	
	override private function keyPressEvent(e:KeyEvent) {
		super.keyPressEvent(e);
		// scroll value
	}
	
	override private function pointerPressEvent(e:PointerEvent) {
		super.pointerPressEvent(e);
		signal_sliderPressed.dispatch();
	}
	
	override private function pointerReleaseEvent(e:PointerEvent) {
		super.pointerReleaseEvent(e);
		signal_sliderReleased.dispatch();
	}
	
	override private function pointerMoveEvent(e:PointerEvent) {
		super.pointerMoveEvent(e);
		
		if (pressed) {
			// use local mouse to calculate value
		}
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