package lycan.util;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.helpers.FlxBounds;

class MathUtil {
	public static function lerpBounds(bounds:FlxBounds<Float>, t:Float):Float {
		return FlxMath.lerp(bounds.min, bounds.max, t);
	}
	
}