package lycan.ui.widgets.sliders;

import flixel.FlxSprite;

// Basic horizontal slider with a handle and bar graphic
class SimpleHorizontalSlider extends AbstractSlider {
	private var handleGraphic:FlxSprite;
	private var barGraphic:FlxSprite;
	
	public function new(min:Float, max:Float, value:Float, handleGraphic:FlxSprite, barGraphic:FlxSprite, ?parent:UIObject, ?name:String) {
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
			maxWidth = cast Math.max(maxWidth, graphic.width);
			maxHeight = cast Math.max(maxHeight, graphic.height);
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
			var nextX = barGraphic.x + (barGraphic.width * (value / maximum) - (handleGraphic.width / 2));
			var nextY = barGraphic.y + (barGraphic.height / 2) - (handleGraphic.height / 2);
			
			handleGraphic.x = Std.int(nextX);
			handleGraphic.y = Std.int(nextY);
		}
	}
	
	private function updateBarPosition():Void {
		if(barGraphic != null) {
			var nextX = x + width / 2 - barGraphic.width / 2;
			var nextY = y + height / 2 - barGraphic.height / 2;
			
			barGraphic.x = Std.int(nextX);
			barGraphic.y = Std.int(nextY);
		}
	}
}