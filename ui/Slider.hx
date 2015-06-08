package lycan.ui;

import flixel.addons.ui.FlxSlider;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Slider extends FlxSlider {

	public function new(object:Dynamic, varString:String, x:Float, y:Float, minValue:Float, maxValue:Float, width:Int) {
		super(object, varString, x, y, minValue, maxValue, width, 40, 3, FlxColor.WHITE);
		
		inputArea.width += 40;
		inputArea.x -= 20;
		
		hoverAlpha = 1;
	}
	
	override public function createHandle():Void {
		handle = new SliderHandle(offset.x, offset.y);
		handle.y += handle.frameHeight / 2;
	}
	
	
	
}

class SliderHandle extends FlxSprite {
	public function new(x:Float, y:Float) {
		super(x, y, "assets/images/gear1.png");
		setSize(3, 3);
		centerOffsets();
		
	}
	
	override public function set_x(x:Float):Float {
		angle = x * 1.5;
		return super.set_x(x);
	}
}