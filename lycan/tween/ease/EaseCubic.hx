package lycan.tween.ease;

/**
 * Cubic easing equations.
 */
class EaseCubic {
    public inline static function inCubic(t:Float):Float {
        return t * t * t;
    }

    public inline static function outCubic(t:Float):Float {
        t -= 1;
        return t * t * t + 1;
    }

    public inline static function inOutCubic(t:Float):Float {
        t *= 2;
        return (t < 1) ? 0.5 * t * t * t : 0.5 * ((t -= 2)* t * t + 2);
    }

    public inline static function outInCubic(t:Float):Float {
        return (t < 0.5) ? outCubic(2 * t) / 2 : inCubic(2 * t - 1) / 2 + 0.5;
    }
}