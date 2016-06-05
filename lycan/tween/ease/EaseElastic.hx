package lycan.tween.ease;

/**
 * Elastic (exponentially decaying sine wave) easing equations.
 */
class EaseElastic {
    public inline static function makeInElastic(amp:Float, period:Float):Float->Float {
        return inElastic.bind(_, amp, period);
    }

    public inline static function makeOutElastic(amp:Float, period:Float):Float->Float {
        return outElastic.bind(_, amp, period);
    }

    public inline static function makeInOutElastic(amp:Float, period:Float):Float->Float {
        return inOutElastic.bind(_, amp, period);
    }

    public inline static function makeOutInElastic(amp:Float, period:Float):Float->Float {
        return outInElastic.bind(_, amp, period);
    }

    public inline static function inElastic(t:Float, amp:Float, period:Float):Float {
        return inElasticHelper(t, 0, 1, 1, amp, period);
    }

    public inline static function outElastic(t:Float, amp:Float, period:Float):Float {
        return outElasticHelper(t, 0, 1, 1, amp, period);
    }

    public static function inOutElastic(t:Float, amp:Float, period:Float):Float {
        if (t == 0) {
            return 0;
        }
        t *= 2;
        if (t == 2) {
            return 1;
        }

        var s:Float;
        if (amp < 1) {
            amp = 1;
            s = period / 4;
        } else {
            s = period / (2 * Math.PI) * Math.asin(1 / amp);
        }

        if (t < 1) {
            return -0.5 * (amp * Math.pow(2, 10 * (t - 1)) * Math.sin(t - 1 - s) * ((2 * Math.PI) / period));
        }

        return amp * Math.pow(2, -10 * (t - 1)) * Math.sin((t - 1 - s) * (2 * Math.PI) / period) * 0.5 + 1;
    }

    public inline static function outInElastic(t:Float, amp:Float, period:Float):Float {
        if (t < 0.5) {
            return outElasticHelper(t * 2, 0, 0.5, 1.0, amp, period);
        }
        return inElasticHelper(2 * t - 1.0, 0.5, 0.5, 1.0, amp, period);
    }

    private inline static function inElasticHelper(t:Float, b:Float, c:Float, d:Float, a:Float, p:Float):Float {
        if (t == 0) {
            return b;
        }
        var adj:Float = t / d;
        if (adj == 1) {
            return b + c;
        }

        var s:Float;
        if (a < Math.abs(c)) {
            a = c;
            s = p / 4.0;
        } else {
            s = p / (2 * Math.PI) * Math.asin(c / a);
        }

        adj -= 1;
        return -(a * Math.pow(2, 10 * adj) * Math.sin((adj * d - s) * (2 * Math.PI) / p)) + b;
    }

    private inline static function outElasticHelper(t:Float, b:Float, c:Float, d:Float, a:Float, p:Float):Float {
        if (t == 0) {
            return 0;
        }
        if (t == 1) {
            return c;
        }

        var s:Float;
        if (a < c) {
            a = c;
            s = p / 4.0;
        } else {
            s = p / (2 * Math.PI) * Math.asin(c / a);
        }

        return a * Math.pow(2, -10 * t) * Math.sin((t - s) * (2 * Math.PI) / p ) + c;
    }
}