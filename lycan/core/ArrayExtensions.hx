package lycan.core;

// Extension methods for Arrays

class ArrayExtensions {
    // Returns a random element from one of the arrays
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

    // Shuffles the array in-place
    public static function shuffle<T>(array:Array<T>):Void {
        var i = array.length;
        while (i > 0) {
            var idx = Std.random(i);
            var tmp = array[--i];
            array[i] = array[idx];
            array[idx] = tmp;
        }
    }

    // Returns a random element from the array
    inline public static function randomElement<T>(array:Array<T>):Null<T> {
        Sure.sure(array != null && array.length != 0);
        return array[Std.random(array.length)];
    }

    // Array accessor, allows positive out-of-bounds indices to wrap around
    inline public static function wrappedPositiveIndex<T>(array:Array<T>, idx:Int):Null<T> {
        Sure.sure(array != null && array.length != 0);
        Sure.sure(idx >= 0);
        return array[idx % array.length];
    }

    // Array accessor, treats the array as if it is circular
    inline public static function circularIndex<T>(array:Array<T>, idx:Int):Null<T> {
        Sure.sure(array != null && array.length != 0);
        if (idx < 0) {
            return array[idx + (idx % array.length)];
        } else {
            return array[idx % array.length];
        }
    }

    // Returns true if the array contains no null elements
    public static function noNulls<T>(array:Array<T>):Bool {
        for (e in array) {
            if (e == null) {
                return false;
            }
        }
        return true;
    }

    // Returns the index of the element in the range min,max - numeric type version
    // NOTE requires a sorted array, non-empty array
    // Returns the index of the element or, if one is not found, negative value of the index where the element would be inserted
    public static function binarySearch<T:Float>(a:Array<T>, x:T, min:Int, max:Int):Int {
        Sure.sure(a != null);
        Sure.sure(min >= 0 && min < a.length);
        Sure.sure(max >= 0 && max < a.length);

        var low:Int = min;
        var high:Int = max + 1;
        var middle:Int;

        while (low < high) {
            middle = low + ((high - low) >> 1);
            if (a[middle] < x) {
                low = middle + 1;
            } else {
                high = middle;
            }
        }

        if (low <= max && (a[low] == x)) {
            return low;
        } else {
            return ~low;
        }
    }

    // Returns the index of the element in the range min,max
    // NOTE requires a sorted, non-empty array
    // Returns the index of the element or, if one is not found, negative value of the index where the element would be inserted
    public static function binarySearchCmp<T>(a:Array<T>, x:T, min:Int, max:Int, comparator:T->T->Int):Int {
        Sure.sure(a != null);
        Sure.sure(min >= 0 && min < a.length);
        Sure.sure(max >= 0 && max < a.length);
        Sure.sure(comparator != null);

        var low:Int = min;
        var high:Int = max + 1;
        var middle:Int;

        while (low < high) {
            middle = low + ((high - low) >> 1);
            if (comparator(a[middle], x) < 0) {
                low = middle + 1;
            } else {
                high = middle;
            }
        }

        if (low <= max && comparator(a[low], x) == 0) {
            return low;
        } else {
            return ~low;
        }
    }

    // Returns the index of the element in the range min,max
    // NOTE requires a sorted, non-empty array
    // Returns the index of the element or, if one is not found, negative value of the index where the element would be inserted
    public static function binarySearchCmpNumeric<T, V:Float>(a:Array<T>, x:V, min:Int, max:Int, comparator:T->V->Int):Int {
        Sure.sure(a != null);
        Sure.sure(min >= 0 && min < a.length);
        Sure.sure(max >= 0 && max < a.length);
        Sure.sure(comparator != null);

        var low:Int = min;
        var high:Int = max + 1;
        var middle:Int;

        while (low < high) {
            middle = low + ((high - low) >> 1);
            if (comparator(a[middle], x) < 0) {
                low = middle + 1;
            } else {
                high = middle;
            }
        }

        if (low <= max && comparator(a[low], x) == 0) {
            return low;
        } else {
            return ~low;
        }
    }
}