package lycan.tweens.ease;

/**
 * Atan easing equations.
 */
class EaseAtan {
	public inline static function makeInAtan(a:Float = 15):Float->Float {
		return inAtan.bind(_, a);
	}

	public inline static function makeOutAtan(a:Float = 15):Float->Float {
		return outAtan.bind(_, a);
	}

	public inline static function makeInOutAtan(a:Float = 15):Float->Float {
		return inOutAtan.bind(_, a);
	}

	public inline static function inAtan(t:Float, a:Float = 15):Float {
		var m:Float = Math.atan(a);
		return Math.atan((t - 1) * a) / m + 1;
	}

	public inline static function outAtan(t:Float, a:Float = 15):Float {
		return Math.atan(t * a)  / 2;
	}

	public inline static function inOutAtan(t:Float, a:Float = 15):Float {
		var m:Float = Math.atan(0.5 * a);
		return Math.atan((t - 0.5) * a) / (2 * m) + 0.5;
	}
}