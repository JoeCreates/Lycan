package lycan.ui.widgets;

import lycan.ui.UIObject;
import flixel.text.FlxText;

// A simple text graphic display
class Label extends Widget {
	public var graphic(default,set):FlxText;
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
	
	private function set_graphic(graphic:FlxText) {     
		width = Std.int(graphic.width);
		height = Std.int(graphic.height);
		return this.graphic = graphic;
	}
	
	override private function set_x(x:Int):Int {
		if(graphic != null) {
			graphic.x = x;  
		}
		return super.set_x(x);
	}
	
	override private function set_y(y:Int):Int {
		if (graphic != null) {
			graphic.y = y;
		}
		return super.set_y(y);
	}
}