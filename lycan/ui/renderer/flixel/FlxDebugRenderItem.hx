package lycan.ui.renderer.flixel;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import lycan.ui.renderer.IRenderItem;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

class FlxDebugRenderItem implements IRenderItem {
	public var graphic:FlxSprite = new FlxSprite();
	
	public function new(w:Int, h:Int, ?color:FlxColor) {
		if (color == null) {
			color = FlxColor.fromRGB(Std.int(Math.random() * 255), Std.int(Math.random() * 255), Std.int(Math.random() * 255), 128);
		}
		
		graphic.makeGraphic(w, h, color);
		set_width(cast graphic.width); 
		set_height(cast graphic.height);
	}
	
	public function addTo(group:FlxGroup) {
		group.add(graphic);
		return this;
	}
	
	public function removeFrom(group:FlxGroup) {
		group.remove(graphic);
		return this;
	}
	
	public function get_x():Int {
		return cast graphic.x;
	}
	
	public function set_x(x:Int):Int {
		return cast graphic.x = x;
	}
	
	public function get_y():Int {
		return cast graphic.y;
	}
	
	public function set_y(y:Int):Int {
		return cast graphic.y = y;
	}
	
	public function get_width():Int {
		return cast graphic.width;
	}
	
	public function set_width(width:Int):Int {
		return cast graphic.width = width;
	}
	
	public function get_height():Int {
		return cast graphic.height;
	}
	
	public function set_height(height:Int):Int {
		return cast graphic.height = height;
	}
	
	public function get_scale():FlxPoint {
		return graphic.scale;
	}
	
	public function set_scale(scale:FlxPoint):FlxPoint {
		//return graphic.scale = scale;
		return scale; // TODO
	}
	
	public function show():Void {
		graphic.visible = true;
	}
	
	public function hide():Void {
		graphic.visible = false;
	}
}