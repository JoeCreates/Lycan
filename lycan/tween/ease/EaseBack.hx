package lycan.tween.ease;

/**
 * Overshooting cubic easing equations.
 */
class EaseBack {
	public inline static function makeInBack(s:Float = 1.70158):Float->Float {
		return inBack.bind(_, s);
	}

	public inline static function makeOutBack(s:Float = 1.70158):Float->Float {
		return outBack.bind(_, s);
	}

	public inline static function makeInOutBack(s:Float = 1.70158):Float->Float {
		return inOutBack.bind(_, s);
	}

	public inline static function makeOutInBack(s:Float = 1.70158):Float->Float {
		return outInBack.bind(_, s);
	}

	public inline static function inBack(t:Float, s:Float = 1.70158):Float {
		return t * t * ((s + 1) * t - s);
	}

	public inline static function outBack(t:Float, s:Float = 1.70158):Float {
		t -= 1;
		return t * t * ((s + 1) * t + s) + 1;
	}

	public inline static function inOutBack(t:Float, s:Float = 1.70158):Float {
		t *= 2;
		s *= 1.525;
		return (t < 1) ? 0.5 * (t * t * ((s + 1) * t - s)) : 0.5 * ((t -= 2) * t * ((s + 1) * t + s) + 2);
	}

	public inline static function outInBack(t:Float, s:Float = 1.70158):Float {
		return (t < 0.5) ? outBack(2 * t, s) / 2 : inBack(2 * t - 1, s) / 2 + 0.5;
	}
}