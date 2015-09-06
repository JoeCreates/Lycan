package lycan.util;

// Extension methods for Arrays

// TODO see thx.core implementations
class ArrayExtensions {
	inline public static function randomElement<T>(array:Array<T>):Null<T> {
		return array[Std.random(array.length)];
	}
}