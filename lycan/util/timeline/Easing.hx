package lycan.util.timeline;

// Easing equations in this file were derived from The Cinder Project (http://libcinder.org/) held under the Modified BSD license:

/*
Copyright (c) 2010, The Cinder Project

Redistribution and use in source and binary forms, with or without modification, are permitted provided that
the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and
the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*/

class EaseLinear {	
	inline public static function none(t:Float):Float {
		return t;
	}
}

class EaseQuad {	
	inline public static function inQuad(t:Float):Float {
		return t * t;
	}
	
	inline public static function outQuad(t:Float):Float {
		return -t * (t - 2);
	}
	
	inline public static function inOutQuad(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t : t -= 1; -0.5 * ((t) * (t - 2) - 1);
	}
	
	inline public static function outInQuad(t:Float):Float {
		return (t < 0.5) ? outQuad(t * 2) * 0.5 : inQuad((t * 2) - 1) * 0.5 + 0.5;
	}
}

class EaseCubic {
	inline public static function inCubic(t:Float):Float {
		return t * t * t;
	}
	
	inline public static function outCubic(t:Float):Float {
		t -= 1;
		return t * t * t + 1;
	}
	
	inline public static function inOutCubic(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t : t -= 2; 0.5 * (t * t * t + 2);
	}
	
	inline public static function outInCubic(t:Float):Float {
		return (t < 0.5) ? outCubic(2 * t) / 2 : inCubic(2 * t - 1) / 2 + 0.5;
	}
}

class EaseQuartic {
	inline public static function inQuart(t:Float):Float {
		return t * t * t * t;
	}
	
	inline public static function outQuart(t:Float):Float {
		t -= 1;
		return -(t * t * t * t - 1);
	}
	
	inline public static function inOutQuart(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t * t : t -= 2; -0.5 * (t * t * t * t - 2);
	}
	
	inline public static function outInQuart(t:Float):Float {
		return (t < 0.5) ? outQuart(2 * t) / 2 : inQuart(2 * t - 1) / 2 + 0.5;
	}
}

class EaseQuintic {
	inline public static function inQuint(t:Float):Float {
		return t * t * t * t * t;
	}
	
	inline public static function outQuint(t:Float):Float {
		t -= 1;
		return t * t * t * t * t + 1;
	}
	
	inline public static function inOutQuint(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t * t * t : t -= 2; 0.5 * (t * t * t * t * t + 2);
	}
	
	inline public static function outInQuint(t:Float):Float {
		return (t < 0.5) ? outQuint(2 * t) / 2 : inQuint(2 * t - 1) / 2 + 0.5;
	}
}

class EaseExpo {
	inline public static function inExpo(t:Float):Float {
		return (t == 0) ? 0 : Math.pow(2, 10 * (t - 1));
	}
	
	inline public static function outExpo(t:Float):Float {
		return (t == 1) ? 1 : - Math.pow(2, -10 * t) + 1;
	}
	
	inline public static function inOutExpo(t:Float):Float {
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
	
	inline public static function outInExpo(t:Float):Float {
		return (t < 0.5) ? outExpo(2 * t) / 2 : inExpo(2 * t - 1) / 2 + 0.5;
	}
}

class EaseCircular {
	inline public static function inCircular(t:Float):Float {
		return -(Math.sqrt(1 - t * t) - 1);
	}
	
	inline public static function outCircular(t:Float):Float {
		t -= 1;
		return Math.sqrt(1 - t * t);
	}
	
	inline public static function inOutCircular(t:Float):Float {
		t *= 2;
		return (t < 1) ? -0.5 * (Math.sqrt(1 - t * t) - 1) : t -= 2; 0.5 * (Math.sqrt(1 - t * t) + 1);
	}
	
	inline public static function outInCircular(t:Float):Float {
		return (t < 0.5) ? outCircular(2 * t) / 2 : inCircular(2 * t - 1) / 2 + 0.5;
	}
}

class EaseSine {
	inline public static function inSine(t:Float):Float {
		return -Math.cos(t * Math.PI / 2.0) + 1;
	}
	
	inline public static function outSine(t:Float):Float {
		return Math.sin(t * Math.PI / 2.0);
	}
	
	inline public static function inOutSine(t:Float):Float {
		return -0.5 * (Math.cos(Math.PI * t) - 1);
	}
	
	inline public static function outInSine(t:Float):Float {
		return (t < 0.5) ? outSine(2 * t) / 2 : inSine(2 * t - 1) / 2 + 0.5;
	}
}

class EaseBounce {
	// TODO use partially applied arguments using function bindings to make these Float->Floats
	
	inline public static function inBounce(t:Float, a:Float):Float {
		return 1 - outBounceHelper(1 - t, 1, a);
	}
	
	inline public static function outBounce(t:Float, a:Float):Float {
		return outBounceHelper(t, 1, a);
	}
	
	inline public static function inOutBounce(t:Float, a:Float):Float {
		return (t < 0.5) ? inBounce(2 * t, a) / 2 : (t == 1) ? 1 : outBounce(2 * t - 1, a) / 2 + 0.5;
	}
	
	inline public static function outInBounce(t:Float, a:Float):Float {
		return (t < 0.5) ? outBounceHelper(t * 2, 0.5, a) : 1 - outBounceHelper(2 - 2 * t, 0.5, a);
	}
	
	inline private static function outBounceHelper(t:Float, b:Float, c:Float):Float {
		if (t == 1) {
			return b;
		} else if (t < (1 / 2.75)) {
			return c * (7.5625 * t * t);
		} else if (t < (2 / 2.75)) {
			t -= 1.5 / 2.75;
			return -c * (1 - (7.5625 * t * t + 0.75)) + b;
		} else if (t < (2.5 / 2.75)) {
			t -= 2.25 / 2.75;
			return -c * (1 - (7.5625 * t * t + 0.9375)) + b;
		} else {
			t -= 2.625 / 2.75;
			return -c * (1 - (7.5625 * t * t + 0.984375)) + b;
		}
	}
}

// TODO
/*
class EaseBack {
	inline public static function easeInBack(t:Float, s:Float):Float {
		
	}
	
	inline public static function easeOutBack(t:Float, s:Float):Float {
		
	}
	
	inline public static function easeInOutBack(t:Float, s:Float):Float {
		
	}
	
	inline public static function easeOutInBack(t:Float, s:Float):Float {
		
	}
}

class EaseElastic {
	inline public static function easeInElastic(t:Float, amp:Float, period:Float):Float {
		
	}
	
	inline public static function easeOutElastic(t:Float, amp:Float, period:Float):Float {
		
	}
	
	inline public static function easeInOutElastic(t:Float, amp:Float, period:Float):Float {
		
	}
	
	inline public static function easeOutInElastic(t:Float, amp:Float, period:Float):Float {
		
	}
	
	inline private static function easeInElasticHelper(t:Float, b:Float, c:Float, d:Float, a:Float, p:Float):Float {
		
	}
	
	inline private static function easeOutElasticHelper(t:Float, c:Float, a:Float, p:Float):Float {
		
	}
}

class EaseAtan {
	inline public static function easeInAtan(t:Float, a:Float):Float {
		
	}
	
	inline public static function easeOutAtan(t:Float, a:Float):Float {
		
	}
	
	inline public static function easeInOutAtan(t:Float, a:Float):Float {
		
	}
}

// TODO cubic hermite spline interpolator
class EaseCubicHermite {
	inline public static function easeHermite(t:Float, accel:Float, cruise:Float, decel:Float):Float {
		
	}
	
	inline private static function cubicHermite(t:Float, p0:Float, p1:Float, m0:Float, m1:Float):Float {
		
	}
}
*/