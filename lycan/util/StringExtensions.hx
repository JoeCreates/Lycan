package lycan.util;

using StringTools;

class StringExtensions {	
	// NOTE this will be slow
	public static inline function reverse(s:String):String {
		Sure.sure(s != null);
		var arr:Array<String> = s.split("");
		arr.reverse();
		return arr.join("");
	}
}