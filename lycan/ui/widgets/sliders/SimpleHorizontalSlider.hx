package lycan.ui.widgets.sliders;

import lycan.ui.renderer.IRenderItem;

// Basic horizontal slider with a handle and bar graphic
class SimpleHorizontalSlider extends AbstractSlider {
	private var handleGraphic:IRenderItem;
	private var barGraphic:IRenderItem;
	
	public function new(min:Float, max:Float, value:Float, handleGraphic:IRenderItem, barGraphic:IRenderItem, ?parent:UIObject, ?name:String) {
		super(min, max, value, parent, name);
		this.handleGraphic = handleGraphic;
		this.barGraphic = barGraphic;
		graphics.push(handleGraphic);
		graphics.push(barGraphic);
		
		updateGeometry();
		updateBarPosition();
		updateHandlePosition();
		
		signal_valueChanged.add(function(v:Float) {
			updateHandlePosition();
		});
	}
	
	override public function updateGeometry() {
		super.updateGeometry();
		
		var maxWidth:Int = 0;
		var maxHeight:Int = 0;
		
		for (graphic in [barGraphic]) {
			maxWidth = cast Math.max(maxWidth, graphic.get_width());
			maxHeight = cast Math.max(maxHeight, graphic.get_height());
		}
		
		width = maxWidth;
		height = maxHeight;
	}
	
	override private function set_x(x:Int):Int {
		super.set_x(x);
		updateBarPosition();
		updateHandlePosition();
		return x;
	}
	
	override private function set_y(y:Int):Int {
		super.set_y(y);
		updateBarPosition();
		updateHandlePosition();
		return y;
	}
	
	private function updateHandlePosition():Void {
		if(handleGraphic != null) {
			var nextX = barGraphic.get_x() + (barGraphic.get_width() * (value / maximum) - (handleGraphic.get_width() / 2));
			var nextY = barGraphic.get_y() + (barGraphic.get_height() / 2) - (handleGraphic.get_height() / 2);
			
			handleGraphic.set_x(Std.int(nextX));
			handleGraphic.set_y(Std.int(nextY));
		}
	}
	
	private function updateBarPosition():Void {
		if(barGraphic != null) {
			var nextX = x + width / 2 - barGraphic.get_width() / 2;
			var nextY = y + height / 2 - barGraphic.get_height() / 2;
			
			barGraphic.set_x(Std.int(nextX));
			barGraphic.set_y(Std.int(nextY));
		}
	}
}