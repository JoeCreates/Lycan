package lycan.core;

import flixel.FlxCamera;

class LycanCamera extends FlxCamera {
	// TODO should the new screenshake implementations etc go in here?

	public function new(x:Int, y:Int, width:Int, height:Int, zoom:Float) {
		super(x, y, width, height, zoom);
	}
}