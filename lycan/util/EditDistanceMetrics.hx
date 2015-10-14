package lycan.util;

import haxe.ds.Vector;

using lycan.util.IntExtensions;

class EditDistanceMetrics {
	// Returns the number of single-character edits (insertions, deletions and replacements) needed to transform the source into the target
	// Fast iterative method that doesn't create a whole distance table up front
	public static function levenshtein(source:String, target:String):Int {
		Sure.sure(source != null && target != null);
		var slen:Int = source.length;
		var tlen:Int = target.length;
		
		if (slen == 0) {
			return tlen;
		}
		if (tlen == 0) {
			return slen;
		}
		
		var costs:Vector<Int> = new Vector(tlen + 1);
		for (i in 0...costs.length) {
			costs[i] = i;
		}
		
		var s:Int = 0;
		while (s < source.length) {
			costs[0] = s + 1;
			var corner:Int = s;
			var t:Int = 0;
			while (t < target.length) {
				var upper:Int = costs[t + 1];
				if (source.charAt(s) == target.charAt(t)) {
					costs[t + 1] = corner;
				} else {
					var tc:Int = upper < corner ? upper : corner;
					costs[t + 1] = (costs[t] < tc ? costs[t] : tc) + 1;
				}
				corner = upper;
				t++;
			}
			s++;
		}
		
		return costs[costs.length - 1];
	}
	
	// Like levenshtein distance, but may also transpose adjacent symbols
	// Returns the distance table for finding optimal sequences
	public static function damerauLevenshteinMatrix(source:String, target:String, enableTransposition:Bool = true):Vector<Int> {
		Sure.sure(source != null && target != null);
		var w:Int = source.length;
		var h:Int = target.length;
		
		if (w == 0 || h == 0) {
			return new Vector<Int>(0);
		}
		
		w += 1;
		h += 1;
		var costs:Vector<Int> = new Vector(w * h);
		for (i in 0...w) {
			costs[i] = i;
		}
		for (j in 1...h) {
			costs[j * w] = j;
		}
		
		var cost:Int = 0;
		for (x in 1...w) {
			for (y in 1...h) {
				if (source.charAt(x - 1) == target.charAt(y - 1)) {
					cost = 0;
				} else {
					cost = 1;
				}
				
				costs[x + y * w] = IntExtensions.min(costs[(x - 1) + ((y) * w)] + 1,
									  IntExtensions.min(costs[(x) + ((y - 1) * w)] + 1,
														costs[(x - 1) + ((y - 1) * w)] + cost)); // Deletion, insertion, substitution
				
				if (enableTransposition && x > 1 && y > 1 && source.charAt(x) == target.charAt(y - 1) && source.charAt(x - 1) == target.charAt(y)) {
					costs[x + y * w] = IntExtensions.min(costs[x + y * w], costs[x - 2 + ((y - 2) * w)] + cost); // Transposition
				}
			}
		}
		
		return costs;
	}
	
	// Like levenshtein distance, but also transposes adjacent symbols
	public static inline function damerauLevenshtein(source:String, target:String, enableTransposition:Bool = true):Int {
		if (source.length == 0) {
			return target.length;
		} 
		if (target.length == 0) {
			return source.length;
		}
		var table = damerauLevenshteinMatrix(source, target, enableTransposition);
		return table[table.length - 1];
	}
	
	// Returns the Jaro distance between the strings, 0 is perfect match, 1 is no match
	public static function jaro(first:String, second:String):Float {
		var f:Int = first.length;
		var s:Int = second.length;
		
		// If both are empty, match, if only one empty, mismatch
		if (f == 0) {
			return s == 0 ? 0.0 : 1.0;
		}
		
		var matchDistance:Int = Std.int(IntExtensions.max(f, s) / 2 - 1);
		
		return 1; // TODO
	}
	
	// Returns the Jaro-Winkler distance between the strings, 0 is perfect match, 1 is no match
	// Winkler modification makes mismatches at the ends more significant
	// TODO
	public static function jaroWinkler(first:String, second:String, winklerPrefixLength:Int = 4, winklerSimilarityThreshold:Float = 0.7):Float {
		if (first == second) {
			return 0;
		}
		
		return 1;
	}
	
	// Returns the Monge-Elkan distance between the strings, 0 is perfect match, 1 is no match
	// Uses the Jaro distance as the inner similarity method
	// TODO
	public static function mongeElkan(first:String, second:String, separator:String = " "):Float {
		return 0;
	}
}