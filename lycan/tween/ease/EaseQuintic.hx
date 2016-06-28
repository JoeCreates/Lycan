package lycan.tween.ease;

/**
 * Quintic easing equations.
 */
class EaseQuintic {
	public inline static function inQuint(t:Float):Float {
		return t * t * t * t * t;
	}

	public inline static function outQuint(t:Float):Float {
		t -= 1;
		return t * t * t * t * t + 1;
	}

	public inline static function inOutQuint(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t * t * t : 0.5 * ((t -= 2) * t * t * t * t + 2);
	}

	public inline static function outInQuint(t:Float):Float {
		return (t < 0.5) ? outQuint(2 * t) / 2 : inQuint(2 * t - 1) / 2 + 0.5;
	}
}