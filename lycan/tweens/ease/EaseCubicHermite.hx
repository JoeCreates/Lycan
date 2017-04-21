package lycan.tweens.ease;

/**
 * Cubic hermite interpolators.
 * @see https://en.wikipedia.org/wiki/Cubic_Hermite_spline
 */
class EaseCubicHermite {
	public inline static function makeHermite(accelTime:Float, cruiseTime:Float, decelTime:Float):Float->Float {
		return hermite.bind(_, accelTime, cruiseTime, decelTime);
	}

	public inline static function hermite(t:Float, accelTime:Float, cruiseTime:Float, decelTime:Float):Float {
		var v:Float = 1 / (accelTime / 2 + cruiseTime + decelTime / 2);
		var x1:Float = v * accelTime / 2;
		var x2:Float = v * cruiseTime;
		var x3:Float = v * decelTime / 2;

		if (t < accelTime) {
			return cubicHermite(t / accelTime, 0, x1, 0, x2 / cruiseTime * accelTime);
		} else if (t <= accelTime + cruiseTime) {
			return x1 + x2 * (t - accelTime) / cruiseTime;
		} else {
			return cubicHermite((t - accelTime - cruiseTime) / decelTime, x1 + x2, 1, x2 / cruiseTime * decelTime, 0);
		}
	}

	private inline static function cubicHermite(t:Float, start:Float, end:Float, stan:Float, etan:Float):Float {
		var t2 = t * t;
		var t3 = t2 * t;
		return (2 * t3 - 3 * t2 + 1) * start + (t3 - 2 * t2 + t) * stan + ( -2 * t3 + 3 * t2) * end + (t3 - t2) * etan;
	}
}