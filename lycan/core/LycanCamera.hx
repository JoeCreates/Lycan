package lycan.core;

import flixel.FlxG;
import flixel.FlxCamera;

class LycanCamera extends FlxCamera {
	
	public var roundScroll:Bool;
	
	public function new(x:Int = 0, y:Int = 0, width:Int, height:Int, zoom:Float) {
		super(x, y, width, height, zoom);
		roundScroll = !FlxG.renderBlit;
	}
	// TODO should the new screenshake implementations etc go in here?
	
	override function updateScroll() {
		super.updateScroll();
		if (roundScroll) {
			scroll.x = Math.round(scroll.x * zoom) / zoom;
			scroll.y = Math.round(scroll.y * zoom) / zoom;
		}
	}
}