package lycan.util.ext;

// Extension methods for Ints
class IntExt {
	inline public static function abs(v:Int):Int {
		if (v < 0) {
			return -v;
		}
		return v;
	}

	inline public static function clamp(v:Int, min:Int, max:Int):Int {
		if (v < min) {
			return min;
		}
		if (v > max) {
			return max;
		}
		return v;
	}

	inline public static function clampSym(v:Int, bound:Int):Int {
		return clamp(v, bound, bound);
	}

	inline public static function even(v:Int):Bool {
		return v % 2 == 0;
	}

	inline public static function odd(v:Int):Bool {
		return v % 2 != 0;
	}

	inline public static function toBool(v:Int):Bool {
		return v != 0;
	}

	inline public static function isPow2(v:Int):Bool {
		return (v > 0) && ((v & (v - 1)) == 0);
	}

	inline public static function sign(v:Int):Int {
		return v > 0 ? 1 : v < 0 ? -1 : 0;
	}
}