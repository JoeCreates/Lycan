package lycan.tween.ease;

/**
 * Circular easing equations.
 */
class EaseCircular {
    public inline static function inCirc(t:Float):Float {
        return -(Math.sqrt(1 - t * t) - 1);
    }

    public inline static function outCirc(t:Float):Float {
        t -= 1;
        return Math.sqrt(1 - t * t);
    }

    public inline static function inOutCirc(t:Float):Float {
        t *= 2;
        return (t < 1) ? -0.5 * (Math.sqrt(1 - t * t) - 1) : 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1);
    }

    public inline static function outInCirc(t:Float):Float {
        return (t < 0.5) ? outCirc(2 * t) / 2 : inCirc(2 * t - 1) / 2 + 0.5;
    }
}