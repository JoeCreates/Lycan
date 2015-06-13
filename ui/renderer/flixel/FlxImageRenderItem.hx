package source.lycan.ui.renderer.flixel;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import lycan.ui.renderer.IRenderItem;
import flixel.group.FlxGroup;

class FlxImageRenderItem implements IRenderItem {
	public var graphic:FlxSprite;
	
	public function new(graphic:FlxSprite) {
		this.graphic = graphic;
	}
	
	public function addTo(group:FlxGroup) {
		group.add(graphic);
	}
	
	public function removeFrom(group:FlxGroup) {
		group.remove(graphic);
	}
	
	public function get_x():Int {
		return graphic.x;
	}
	
	public function set_x(x:Int):Int {
		return graphic.x = x;
	}
	
	public function get_y():Int {
		return graphic.y;
	}
	
	public function set_y(y:Int):Int {
		return graphic.y = y;
	}
	
	public function get_width():Int {
		return graphic.width;
	}
	
	public function set_width(width:Int):Int {
		return graphic.width = width;
	}
	
	public function get_height():Int {
		return graphic.height;
	}
	
	public function set_height(height:Int):Int {
		return graphic.height = height;
	}
	
	public function get_scale():FlxPoint {
		return graphic.scale;
	}
	
	public function set_scale(scale:FlxPoint):FlxPoint {
		return graphic.scale = scale;
	}
}