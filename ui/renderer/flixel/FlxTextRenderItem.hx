package source.lycan.ui.renderer.flixel;
import flixel.text.FlxText;
import lycan.ui.renderer.flixel.IFlxRenderItem;

import source.lycan.ui.renderer.ITextRenderItem;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;

class FlxTextRenderItem implements IFlxRenderItem implements ITextRenderItem {
	public var graphic:FlxText;
	
	public function new(graphic:FlxText) {
		this.graphic = graphic;
	}
	
	public function addTo(group:FlxGroup):FlxTextRenderItem {
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
		//return cast graphic.scale = scale;
		return scale; // TODO
	}
	
	public function get_text():String {
		return cast graphic.text;
	}
	
	public function set_text(text:String):String {
		return cast graphic.text = text;
	}
	
	public function set_sprite(sprite:FlxText):FlxText {
		return this.graphic = sprite;
	}
}