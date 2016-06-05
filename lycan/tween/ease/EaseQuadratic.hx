package lycan.tween.ease;

/**
 * Quadratic easing equations.
 */
class EaseQuadratic {
    public inline static function inQuad(t:Float):Float {
        return t * t;
    }

    public inline static function outQuad(t:Float):Float {
        return -t * (t - 2);
    }

    public inline static function inOutQuad(t:Float):Float {
        t *= 2;
        return (t < 1) ? 0.5 * t * t : -0.5 * ((t - 1) * (t - 3) - 1);
    }

    public inline static function outInQuad(t:Float):Float {
        return (t < 0.5) ? outQuad(t * 2) * 0.5 : inQuad((t * 2) - 1) * 0.5 + 0.5;
    }
}