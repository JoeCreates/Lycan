package lycan.util.timeline;
import flixel.input.FlxAccelerometer;

class Easing {
	inline public static function easeNone(t:Float):Float {
		return t;
	}
	
	inline public static function easeInQuad(t:Float):Float {
		return t * t;
	}
	
	inline public static function easeOutQuad(t:Float):Float {
		return -t * (t - 2);
	}
	
	inline public static function easeOutInQuad(t:Float):Float {
		return (t < 0.5) ? easeOutQuad(t * 2) * 0.5 : easeInQuad((t * 2) - 1) * 0.5 + 0.5;
	}
}