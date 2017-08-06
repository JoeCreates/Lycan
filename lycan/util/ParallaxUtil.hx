package lycan.util;

import flixel.FlxCamera;
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
	
	public static function adjustPositionForCamera(sprite:FlxSprite, camera:FlxCamera):Void {
		ParallaxUtil.adjustPositionForScroll(sprite, camera.scroll.x, camera.scroll.y);
	}
	
	public static function parallaxOrigin(origin:Float, cameraPosition:Float, scrollFactor:Float):Float {
		return origin + cameraPosition * (scrollFactor - 1);
	}
	
	/**
	 * Calculate the position in the world an object given its position, scrollFactor and camera's scroll
	 * 
	 * @param	pos The x or y position of the object
	 * @param 	scrollFactor The scrollFactor of the object on the given axis
	 * @param	cameraScroll The camera's scroll position on the given axis
	 * @return The apparent world position of the object on the given axis
	 */
	public static function getWorldPositionAtScroll(pos:Float, scrollFactor:Float, cameraScroll:Float):Float {
		return pos - scrollFactor * cameraScroll + cameraScroll;
	}
	
	public static function getWorldX(spr:FlxSprite, camera:FlxCamera):Float {
		return getWorldPositionAtScroll(spr.x, spr.scrollFactor.x, camera.scroll.x);
	}
	
	public static function getWorldY(spr:FlxSprite, camera:FlxCamera):Float {
		return getWorldPositionAtScroll(spr.y, spr.scrollFactor.y, camera.scroll.y);
	}
}