package lycan.tween.ease;

/**
 * Sinusoidal easing equations.
 */
class EaseSinusoidal {
    public inline static function inSine(t:Float):Float {
        return -Math.cos(t * Math.PI / 2.0) + 1;
    }

    public inline static function outSine(t:Float):Float {
        return Math.sin(t * Math.PI / 2.0);
    }

    public inline static function inOutSine(t:Float):Float {
        return -0.5 * (Math.cos(Math.PI * t) - 1);
    }

    public inline static function outInSine(t:Float):Float {
        return (t < 0.5) ? outSine(2 * t) / 2 : inSine(2 * t - 1) / 2 + 0.5;
    }
}