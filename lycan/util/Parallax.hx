package lycan.util;

import flixel.FlxSprite;

class Parallax {
	 // Set the position of a sprite such that its position is a given value at a given camera scroll
	 // Used for parallax sprites
	public static function setPositionAtScroll(sprite:FlxSprite, x:Float, y:Float, scrollX:Float, scrollY:Float):Void {
		sprite.x = Parallax.parallaxOrigin(x, scrollX, sprite.scrollFactor.x);
		sprite.y = Parallax.parallaxOrigin(y, scrollY, sprite.scrollFactor.y);
	}
	
	public static function adjustPositionForScroll(sprite:FlxSprite, scrollX:Float, scrollY:Float):Void {
		Parallax.setPositionAtScroll(sprite, sprite.x, sprite.y, scrollX, scrollY);
	}
	
	public static function parallaxOrigin(origin:Float, cameraPosition:Float, scrollFactor:Float):Float {
		return origin + cameraPosition * (scrollFactor - 1);
	}
}