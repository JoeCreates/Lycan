package lycan.util.structure.container;

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

	inline public static function hamming(a:Int, b:Int):Int {
		Sure.sure(a >= 0 && b >= 0);
		var distance:Int = 0;
		var diff:Int = a ^ b;
		while (diff != 0) { // Counts the number of set bits in the difference
			distance++;
			diff &= diff - 1;
		}
		return distance;
	}
}

// Helper constants for working with bitsets
@:enum abstract Bits(Int) from Int to Int {
	var BIT_01 = value(0);
	var BIT_02 = value(1);
	var BIT_03 = value(2);
	var BIT_04 = value(3);
	var BIT_05 = value(4);
	var BIT_06 = value(5);
	var BIT_07 = value(6);
	var BIT_08 = value(7);
	var BIT_09 = value(8);
	var BIT_10 = value(9);
	var BIT_11 = value(10);
	var BIT_12 = value(11);
	var BIT_13 = value(12);
	var BIT_14 = value(13);
	var BIT_15 = value(14);
	var BIT_16 = value(15);
	var BIT_17 = value(16);
	var BIT_18 = value(17);
	var BIT_19 = value(18);
	var BIT_20 = value(19);
	var BIT_21 = value(20);
	var BIT_22 = value(21);
	var BIT_23 = value(22);
	var BIT_24 = value(23);
	var BIT_25 = value(24);
	var BIT_26 = value(25);
	var BIT_27 = value(26);
	var BIT_28 = value(27);
	var BIT_29 = value(28);
	var BIT_30 = value(29);
	var BIT_31 = value(30);
	var BIT_32 = value(31);
	var BIT_ALL = -1;

	inline private static function value(index:Int) {
		return 1 << index;
	}
}