package lycan.util.ext;

import flixel.util.FlxStringUtil;
import haxe.ds.StringMap;

using StringTools;

class StringExt {
	public static inline function random(s:String, length:Int, alphabet:String):String {
		for (i in 0...length) {
			s += alphabet.charAt(Std.random(alphabet.length));
		}
		return s;
	}

	// NOTE this will be slow
	public static inline function reverse(s:String):String {
		var a = s.split("");
		a.reverse();
		return a.join("");
	}
	
	public static function parseRange(str:String, delimiter:String = "-"): { min:Float, max:Float } {
		var reg:EReg = new EReg("(\\d+(?:\\.\\d+)?)(?:\\s*" + delimiter + "\\s*)?((\\d+(?:\\.\\d+)?))?", "i");
		reg.match(str);
		
		var isRange:Bool = true;
		try { reg.matched(2); } catch (msg:String) { isRange = false; };
		
		var min:Float = Std.parseFloat(reg.matched(1));
		var max:Float = isRange ? Std.parseFloat(reg.matched(2)) : min;
		
		if (Math.isNaN(max)) max = min;
		
		return {min: min, max: max};
	}
	
	public static function repeat(s:String, times:Int):String {
		var output:String = "";
		for (i in 0...times) {
			output += s;
		}
		return output;
	}

	public static function contains(s:String, substr:String):Bool {
		return s.indexOf(substr) >= 0;
	}

	// Exclusion of some characters e.g. spaces is useful for multi-word anagrams
	public static function isAnagram(a:String, b:String, ?excluding:String):Bool {
		if (excluding != null) {
			a = a.replace(excluding, "");
			b = b.replace(excluding, "");
		}

		if (a.length != b.length) {
			return false;
		}

		var map = new StringMap<Int>();

		for (i in 0...a.length) {
			var ch = a.charAt(i);
			var i = map.get(ch);
			if (i == null) {
				map.set(ch, 1);
			} else {
				map.set(ch, i + 1);
			}
		}

		for (i in 0...b.length) {
			var ch = b.charAt(i);
			var i = map.get(ch);
			if (i == null) {
				return false;
			} else {
				map.set(ch, i - 1);
			}
		}

		for (key in map) {
			if (key != 0) {
				return false;
			}
		}

		return true;
	}
}