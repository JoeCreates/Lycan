package lycan.tween.ease;

/**
 * Quartic easing equations.
 */
class EaseQuartic {
	public inline static function inQuart(t:Float):Float {
		return t * t * t * t;
	}

	public inline static function outQuart(t:Float):Float {
		t -= 1;
		return -(t * t * t * t - 1);
	}

	public inline static function inOutQuart(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t * t : -0.5 * ((t -= 2) * t * t * t - 2);
	}

	public inline static function outInQuart(t:Float):Float {
		return (t < 0.5) ? outQuart(2 * t) / 2 : inQuart(2 * t - 1) / 2 + 0.5;
	}
}