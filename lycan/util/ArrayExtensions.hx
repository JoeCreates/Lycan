package lycan.util;

// Extension methods for Arrays

// TODO see thx.core implementations
class ArrayExtensions {
	public static function randomElementFromArrays<T>(arrays:Array<Array<T>>):Null<T> {
		Sure.sure(arrays != null && arrays.length != 0);
		var totalLength:Int = 0;
		var lengths = [];
		
		for (array in arrays) {
			Sure.sure(array != null && array.length != 0);
			totalLength += array.length;
			lengths.push(totalLength);
		}
		
		var n:Float = Math.random() * totalLength;
		
		var i = 0;
		while (i < lengths.length) {
			if (n < lengths[i]) {
				return randomElement(arrays[i]);
			}
			i++;
		}
		
		throw "Failed to get random element";
	}
	
	inline public static function randomElement<T>(array:Array<T>):Null<T> {
		Sure.sure(array != null && array.length != 0);
		return array[Std.random(array.length)];
	}
	
	public static function noNulls<T>(array:Array<T>):Bool {
		for (e in array) {
			if (e == null) {
				return false;
			}
		}
		return true;
	}
}