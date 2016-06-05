package lycan.util.noise;

// Perlin noise functions in this file were adapted from The Cinder Project (http://libcinder.org/) held under the Modified BSD license

/*
Copyright (c) 2010, The Barbarian Group. All rights reserved.

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

import flixel.math.FlxPoint;

import lycan.core.Limits;

class Perlin {
    public var octaves(default, default):Int;
    public var seed(default, default):Int;

    public function new(octaves:Int = 4, ?seed:Null<Int>) {
        this.octaves = octaves;
        if (seed == null) {
            seed = Std.random(Limits.INT32_MAX);
        }
    }

    // Fractional Brownian motion noise, summed octaves of noise
    public function fBm1d(x:Float):Float {
        var result:Float = 0;
        var amp:Float = 0.5;

        for (i in 0...octaves) {
            result += noise1d(x) * amp;
            x *= 2;
            amp *= 0.5;
        }

        return result;
    }

    public function fBm2d(x:Float, y:Float):Float {
        var result:Float = 0;
        var amp:Float = 0.5;

        for (i in 0...octaves) {
            result += noise2d(x, y) * amp;
            x *= 2;
            y *= 2;
            amp *= 0.5;
        }

        return result;
    }

    // Derivative of fractional Brownian motion
    public function dfBm2d(x:Float, y:Float):FlxPoint {
        var result:FlxPoint = new FlxPoint();

        var amp:Float = 0.5;
        var x:Float = x;
        var y:Float = y;

        for (i in 0...octaves) {
            result.addPoint(dnoise1d(x * amp, y * amp));
            x *= 2;
            y *= 2;
            amp *= 0.5;
        }

        return result;
    }

    // Single octaves of noise
    public function noise1d(x:Float):Float {
        var X:Int = Math.floor(x) & 255;
        x -= Math.ffloor(x);
        var u:Float = fade(x);
        var A:Int = permutations[X];
        var AA:Int = permutations[A];
        var B:Int = permutations[X + 1];
        var BA:Int = permutations[B];
        return lerp(u, grad1d(permutations[AA], x), grad1d(permutations[BA], x - 1));
    }

    public function noise2d(x:Float, y:Float):Float {
        var X:Int = Math.floor(x) & 255;
        var Y:Int = Math.floor(y) & 255;
        x -= Math.ffloor(x);
        y -= Math.ffloor(y);
        var u:Float = fade(x);
        var v:Float = fade(y);
        var A:Int = permutations[X] + Y;
        var AA:Int = permutations[A];
        var AB:Int = permutations[A + 1];
        var B:Int = permutations[X + 1] + Y;
        var BA:Int = permutations[B];
        var BB = permutations[B + 1];
        return lerp(v, lerp(u, grad2d(permutations[AA], x, y), grad2d(permutations[BA], x - 1, y)),
                        lerp(u, grad2d(permutations[AB], x, y - 1), grad2d(permutations[BB], x - 1, y - 1)));
    }

    // Derivative of single octave of noise
    public function dnoise1d(x:Float, y:Float):FlxPoint { // TODO avoid use of flxpoint/pass a reference in as a parameter
        var X:Int = Math.floor(x) & 255;
        var Y:Int = Math.floor(y) & 255;
        x -= Math.ffloor(x);
        y -= Math.ffloor(y);
        var u:Float = fade(x);
        var v:Float = fade(y);
        var du:Float = dfade(x);
        var dv:Float = dfade(y);
        var A:Int = permutations[X] + Y;
        var AA:Int = permutations[A];
        var AB:Int = permutations[A + 1];
        var B:Int = permutations[X + 1] + Y;
        var BA = permutations[B];
        var BB = permutations[B + 1];

        if (du < 0.000001) {
            du = 1.0;
        }
        if (dv < 0.000001) {
            dv = 1.0;
        }

        var a:Float = grad2d(permutations[AA], x, y);
        var b:Float = grad2d(permutations[BA], x - 1, y);
        var c:Float = grad2d(permutations[AB], x, y - 1);
        var d:Float = grad2d(permutations[BB], x - 1, y - 1);

        var k1:Float = b - a;
        var k2:Float = c - a;
        var k4:Float = a - b - c + d;

        return new FlxPoint(du * (k1 + k4 * v), dv * (k2 + k4 * u));
    }

    // Gradients
    private function grad1d(hash:Int, x:Float):Float {
        var h:Int = hash & 15;
        var u:Float = h < 8 ? x : 0;
        var v:Float = h < 4 ? 0 : (h == 12 || h == 14) ? x : 0;
        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
    }

    private function grad2d(hash:Int, x:Float, y:Float):Float {
        var h:Int = hash & 15;
        var u:Float = h < 8 ? x : y;
        var v:Float = h < 4 ? y : (h == 12 || h == 14) ? x : 0;
        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
    }

    private static inline function fade(t:Float):Float {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }

    private static inline function dfade(t:Float):Float {
        return 30 * t * t * (t * (t - 2) + 1);
    }

    private static inline function lerp(t:Float, a:Float, b:Float):Float {
        return a + t * (b - a);
    }

    private static var permutations:Array<Int> = [ 151,160,137,91,90,15,
        131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
        190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
        88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
        77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
        102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
        135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
        5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
        223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
        129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
        251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
        49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
        138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
    ];
}