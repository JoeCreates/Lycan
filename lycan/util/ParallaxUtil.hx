package lycan.util;

import flixel.FlxSprite;

class ParallaxUtil {
	 /**
	  * Set the position of a sprite such that its position is a given value at a given camera scroll
	  * taking into account its scrollFactor
	  * 
	  * @param	sprite The sprite to set the position of
	  * @param	x The x position it should appear to be at
	  * @param	y The y position it should appear to be at
	  * @param	scrollX The camera x scroll where this is the case
	  * @param	scrollY The camera y scroll where this is the case
	  */
	public static function setPositionAtScroll(sprite:FlxSprite, x:Float, y:Float, scrollX:Float, scrollY:Float):Void {
		sprite.x = ParallaxUtil.parallaxOrigin(x, scrollX, sprite.scrollFactor.x);
		sprite.y = ParallaxUtil.parallaxOrigin(y, scrollY, sprite.scrollFactor.y);
	}
	
	/**
	 * Set the position of a sprite to appear at its existing position at a given camera scroll
	 * taking into account its scrollFactor
	 * 
	 * @param	sprite The sprite to reposition
	 * @param	scrollX The camera scroll where the sprites position appears at its own x
	 * @param	scrollY The camera scroll where the sprites position appears at its own y
	 */
	public static function adjustPositionForScroll(sprite:FlxSprite, scrollX:Float, scrollY:Float):Void {
		ParallaxUtil.setPositionAtScroll(sprite, sprite.x, sprite.y, scrollX, scrollY);
	}
	
	public static function parallaxOrigin(origin:Float, cameraPosition:Float, scrollFactor:Float):Float {
		return origin + cameraPosition * (scrollFactor - 1);
	}
}