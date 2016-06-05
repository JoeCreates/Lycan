package lycan.tween.ease;

/**
 * Bounce (exponentially decaying parabolic bounce) easing equations.
 */
class EaseBounce {
    public inline static function makeInBounce(a:Float = 1.70158):Float->Float {
        return inBounce.bind(_, a);
    }

    public inline static function makeOutBounce(a:Float = 1.70158):Float->Float {
        return outBounce.bind(_, a);
    }

    public inline static function makeInOutBounce(a:Float = 1.70158):Float->Float {
        return inOutBounce.bind(_, a);
    }

    public inline static function makeOutInBounce(a:Float = 1.70158):Float->Float {
        return outInBounce.bind(_, a);
    }

    public inline static function inBounce(t:Float, a:Float = 1.70158):Float {
        return 1 - outBounceHelper(1 - t, 1, a);
    }

    public inline static function outBounce(t:Float, a:Float = 1.70158):Float {
        return outBounceHelper(t, 1, a);
    }

    public inline static function inOutBounce(t:Float, a:Float = 1.70158):Float {
        return (t < 0.5) ? inBounce(2 * t, a) / 2 : (t == 1) ? 1 : outBounce(2 * t - 1, a) / 2 + 0.5;
    }

    public inline static function outInBounce(t:Float, a:Float = 1.70158):Float {
        return (t < 0.5) ? outBounceHelper(t * 2, 0.5, a) : 1 - outBounceHelper(2 - 2 * t, 0.5, a);
    }

    private inline static function outBounceHelper(t:Float, b:Float, c:Float):Float {
        if (t == 1) {
            return b;
        } else if (t < (4 / 11)) {
            return b * (7.5625 * t * t);
        } else if (t < (8 / 11)) {
            t -= 6 / 11;
            return -c * (1 - (7.5625 * t * t + 0.75)) + b;
        } else if (t < (10 / 11)) {
            t -= 9 / 11;
            return -c * (1 - (7.5625 * t * t + 0.9375)) + b;
        } else {
            t -= 21 / 22;
            return -c * (1 - (7.5625 * t * t + 0.984375)) + b;
        }
    }
}