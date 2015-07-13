package lycan.util;

class BitSet {
	// Sets the mask bits
	inline public static function add(bits:Int, mask:Int):Int {
		return bits | mask;
	}
	
	// Unsets the mask bits
	inline public static function remove(bits:Int, mask:Int):Int {
		return bits & ~mask;
	}
	
	// Toggles the mask bits
	inline public static function toggle(bits:Int, mask:Int):Int {
		return bits ^ mask;
	}
	
	// True if any mask bits are set in the bitset
	inline public static function containsAny(bits:Int, mask:Int):Bool {
		return bits & mask != 0;
	}
	
	// True if all mask bits are set in the bitset
	inline public static function containsAll(bits:Int, mask:Int):Bool {
		return bits & mask == mask;
	}
	
	// Sets or unsets all the mask bits
	inline public static function set(bits:Int, mask:Int, enabled:Bool):Int {
		return enabled ? add(bits, mask) : remove(bits, mask);
	}
}