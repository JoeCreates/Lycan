package lycan.util.timeline;

// Easing equations in this file were adapted from The Cinder Project (http://libcinder.org/) held under the Modified BSD license
// Documentation and easeOutIn algorithms were originally adapted from Qt: http://qt.nokia.com/products/
// Atan easing functions are copyright Chris MacKenzie
// Cubic hermite implementation based on StackOverflow answer by Roman Zenka: http://stackoverflow.com/a/3367593/1333253

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
		return (t < 1) ? 0.5 * t * t : -0.5 * ((t - 1) * (t - 3) - 1);
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
		return (t < 1) ? 0.5 * t * t * t : 0.5 * ((t -= 2)* t * t + 2);
	}
	
	inline public static function outInCubic(t:Float):Float {
		return (t < 0.5) ? outCubic(2 * t) / 2 : inCubic(2 * t - 1) / 2 + 0.5;
	}
}

class EaseQuart {
	inline public static function inQuart(t:Float):Float {
		return t * t * t * t;
	}
	
	inline public static function outQuart(t:Float):Float {
		t -= 1;
		return -(t * t * t * t - 1);
	}
	
	inline public static function inOutQuart(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t * t : -0.5 * ((t -= 2) * t * t * t - 2);
	}
	
	inline public static function outInQuart(t:Float):Float {
		return (t < 0.5) ? outQuart(2 * t) / 2 : inQuart(2 * t - 1) / 2 + 0.5;
	}
}

class EaseQuint {
	inline public static function inQuint(t:Float):Float {
		return t * t * t * t * t;
	}
	
	inline public static function outQuint(t:Float):Float {
		t -= 1;
		return t * t * t * t * t + 1;
	}
	
	inline public static function inOutQuint(t:Float):Float {
		t *= 2;
		return (t < 1) ? 0.5 * t * t * t * t * t : 0.5 * ((t -= 2) * t * t * t * t + 2);
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

class EaseCirc {
	inline public static function inCirc(t:Float):Float {
		return -(Math.sqrt(1 - t * t) - 1);
	}
	
	inline public static function outCirc(t:Float):Float {
		t -= 1;
		return Math.sqrt(1 - t * t);
	}
	
	inline public static function inOutCirc(t:Float):Float {
		t *= 2;
		return (t < 1) ? -0.5 * (Math.sqrt(1 - t * t) - 1) : 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1);
	}
	
	inline public static function outInCirc(t:Float):Float {
		return (t < 0.5) ? outCirc(2 * t) / 2 : inCirc(2 * t - 1) / 2 + 0.5;
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
	inline public static function makeInBounce(a:Float = 1.70158):Float->Float {
		return inBounce.bind(_, a);
	}
	
	inline public static function makeOutBounce(a:Float = 1.70158):Float->Float {
		return outBounce.bind(_, a);
	}
	
	inline public static function makeInOutBounce(a:Float = 1.70158):Float->Float {
		return inOutBounce.bind(_, a);
	}
	
	inline public static function makeOutInBounce(a:Float = 1.70158):Float->Float {
		return outInBounce.bind(_, a);
	}
	
	inline public static function inBounce(t:Float, a:Float = 1.70158):Float {
		return 1 - outBounceHelper(1 - t, 1, a);
	}
	
	inline public static function outBounce(t:Float, a:Float = 1.70158):Float {
		return outBounceHelper(t, 1, a);
	}
	
	inline public static function inOutBounce(t:Float, a:Float = 1.70158):Float {
		return (t < 0.5) ? inBounce(2 * t, a) / 2 : (t == 1) ? 1 : outBounce(2 * t - 1, a) / 2 + 0.5;
	}
	
	inline public static function outInBounce(t:Float, a:Float = 1.70158):Float {
		return (t < 0.5) ? outBounceHelper(t * 2, 0.5, a) : 1 - outBounceHelper(2 - 2 * t, 0.5, a);
	}
	
	inline private static function outBounceHelper(t:Float, b:Float, c:Float):Float {
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

class EaseBack {
	inline public static function makeInBack(s:Float = 1.70158):Float->Float {
		return inBack.bind(_, s);
	}
	
	inline public static function makeOutBack(s:Float = 1.70158):Float->Float {
		return outBack.bind(_, s);
	}
	
	inline public static function makeInOutBack(s:Float = 1.70158):Float->Float {
		return inOutBack.bind(_, s);
	}
	
	inline public static function makeOutInBack(s:Float = 1.70158):Float->Float {
		return outInBack.bind(_, s);
	}
	
	inline public static function inBack(t:Float, s:Float = 1.70158):Float {
		return t * t * ((s + 1) * t - s);
	}
	
	inline public static function outBack(t:Float, s:Float = 1.70158):Float {
		t -= 1;
		return t * t * ((s + 1) * t + s) + 1;
	}
	
	inline public static function inOutBack(t:Float, s:Float = 1.70158):Float {
		t *= 2;
		s *= 1.525;
		return (t < 1) ? 0.5 * (t * t * ((s + 1) * t - s)) : 0.5 * ((t -= 2) * t * ((s + 1) * t + s) + 2);
	}
	
	inline public static function outInBack(t:Float, s:Float = 1.70158):Float {
		return (t < 0.5) ? outBack(2 * t, s) / 2 : inBack(2 * t - 1, s) / 2 + 0.5; 
	}
}

class EaseElastic {
	inline public static function makeInElastic(amp:Float, period:Float):Float->Float {
		return inElastic.bind(_, amp, period);
	}
	
	inline public static function makeOutElastic(amp:Float, period:Float):Float->Float {
		return outElastic.bind(_, amp, period);
	}
	
	inline public static function makeInOutElastic(amp:Float, period:Float):Float->Float {
		return inOutElastic.bind(_, amp, period);
	}
	
	inline public static function makeOutInElastic(amp:Float, period:Float):Float->Float {
		return outInElastic.bind(_, amp, period);
	}
	
	inline public static function inElastic(t:Float, amp:Float, period:Float):Float {
		return inElasticHelper(t, 0, 1, 1, amp, period);
	}
	
	inline public static function outElastic(t:Float, amp:Float, period:Float):Float {
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
	
	inline public static function outInElastic(t:Float, amp:Float, period:Float):Float {
		if (t < 0.5) {
			return outElasticHelper(t * 2, 0, 0.5, 1.0, amp, period);
		}
		return inElasticHelper(2 * t - 1.0, 0.5, 0.5, 1.0, amp, period);
	}
	
	inline private static function inElasticHelper(t:Float, b:Float, c:Float, d:Float, a:Float, p:Float):Float {
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
	
	inline private static function outElasticHelper(t:Float, b:Float, c:Float, d:Float, a:Float, p:Float):Float {
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

class EaseAtan {
	inline public static function makeInAtan(a:Float = 15):Float->Float {
		return inAtan.bind(_, a);
	}
	
	inline public static function makeOutAtan(a:Float = 15):Float->Float {
		return outAtan.bind(_, a);
	}
	
	inline public static function makeInOutAtan(a:Float = 15):Float->Float {
		return inOutAtan.bind(_, a);
	}
	
	inline public static function inAtan(t:Float, a:Float = 15):Float {
		var m:Float = Math.atan(a);
		return Math.atan((t - 1) * a) / m + 1;
	}
	
	inline public static function outAtan(t:Float, a:Float = 15):Float {
		var m:Float = Math.atan(a);
		return Math.atan(t * a)  / 2;
	}
	
	inline public static function inOutAtan(t:Float, a:Float = 15):Float {
		var m:Float = Math.atan(0.5 * a);
		return Math.atan((t - 0.5) * a) / (2 * m) + 0.5;
	}
}

class EaseCubicHermite {
	inline public static function makeHermite(accelTime:Float, cruiseTime:Float, decelTime:Float):Float->Float {
		return hermite.bind(_, accelTime, cruiseTime, decelTime);
	}
	
	inline public static function hermite(t:Float, accelTime:Float, cruiseTime:Float, decelTime:Float):Float {		
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
	
	inline private static function cubicHermite(t:Float, start:Float, end:Float, stan:Float, etan:Float):Float {
		var t2 = t * t;
		var t3 = t2 * t;
		return (2 * t3 - 3 * t2 + 1) * start + (t3 - 2 * t2 + t) * stan + ( -2 * t3 + 3 * t2) * end + (t3 - t2) * etan;
	}
}