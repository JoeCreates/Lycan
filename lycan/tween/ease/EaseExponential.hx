package lycan.tween.ease;

/**
 * Exponential easing equations.
 */
class EaseExponential {
	public inline static function inExpo(t:Float):Float {
		return (t == 0) ? 0 : Math.pow(2, 10 * (t - 1));
	}

	public inline static function outExpo(t:Float):Float {
		return (t == 1) ? 1 : - Math.pow(2, -10 * t) + 1;
	}

	public inline static function inOutExpo(t:Float):Float {
		if (t == 0) {
			return t;
		}
		if (t == 1) {
			return t;
		}
		t *= 2;
		if (t < 1) {
			return 0.5 * Math.pow(2, 10 * (t - 1));
		}
		return 0.5 * ( -Math.pow(2, -10 * (t - 1)) + 2);
	}

	public inline static function outInExpo(t:Float):Float {
		return (t < 0.5) ? outExpo(2 * t) / 2 : inExpo(2 * t - 1) / 2 + 0.5;
	}
}