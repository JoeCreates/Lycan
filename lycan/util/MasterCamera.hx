package lycan.util;

import flixel.FlxCamera;
import lycan.core.LycanCamera;

class MasterCamera extends LycanCamera {
	public var slaveCameras:Array<FlxCamera>;
	
	public function new(x:Int, y:Int, width:Int, height:Int, zoom:Float) {
		slaveCameras = new Array<FlxCamera>();
		super(x, y, width, height, zoom);
	}
	
	override public function updateScroll():Void {
		super.updateScroll();
		for (c in slaveCameras) {
			c.scroll.copyFrom(scroll);
		}
	}
}