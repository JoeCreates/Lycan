package lycan.util;

import haxe.ds.Vector;

using lycan.util.IntExtensions;

enum EditOperation {
	KEEP(s:String, source:Int); // No-op
	INSERTION(s:String, source:Int, target:Int);
	DELETION(s:String, idx:Int);
	SUBSTITUTION(remove:String, insert:String, idx:Int);
	//TRANSPOSITION // Unimplemented
}

class StringTransforms {
	// Returns the minimal sequence of operations required to convert one string to another
	public static function optimalLevenshteinPath(source:String, target:String, matrix:Vector<Int>):Array<EditOperation> {
		var ops = new Array<EditOperation>();
		
		var x:Int = source.length;
		var y:Int = target.length;
		var w:Int = x + 1;
		var h:Int = y + 1;
		
		trace(matrix);
		
		var current:Int = idx(x, y, w, h); // Bottom right
		//var steps = 0;
		
		while (matrix[current] != 0) {
			var left = idx(x - 1, y, w, h);
			var right = idx(x + 1, y, w, h);
			var upper = idx(x, y - 1, w, h);
			var lower = idx(x, y + 1, w, h);
			var diagonal = idx(x - 1, y - 1, w, h);
			
			current = idx(x, y, w, h);
			
			if (matrix[current] == 0) {
				break;
			}
			
			trace("left: " + left + "(" + matrix[left] + ")" + " right " + right + "(" + matrix[right] + ")" + " upper " + upper + "(" + matrix[upper] + ")" + " diagonal " + diagonal + "(" + matrix[diagonal] + ")" + " current " + current + "(" + matrix[current] + ")");
			
			// If the value of the diagonal cell is smaller or equal to the upper or left cell and the diagonal cell is the same or 1 minus the value of the current cell
			if (matrix[diagonal] <= matrix[left] && matrix[diagonal] <= matrix[upper] && (matrix[current] == matrix[diagonal] || matrix[current] - 1 == (matrix[diagonal]))) {
				// If the value of the diagonal cell is one less than the current cell, then substitute
				if (matrix[current] - 1 == matrix[diagonal]) {
					ops.push(SUBSTITUTION(source.charAt(x - 1), target.charAt(y - 1), x - 1));
					x--;
					y--;
					trace("Diagonal SUBSTITUTION");
				} else {
					ops.push(KEEP(source.charAt(x - 1), x - 1));
					x--;
					y--;
					trace("Diagonal KEEP");
				}
			// Else if the value of the upper cell is smaller or equal to the left cell and the value of the upper cell is the same or 1 minus the current cell
			} else if (matrix[upper] <= matrix[left] && (matrix[current] == matrix[upper] || matrix[current] - 1 == matrix[upper])) {
				ops.push(INSERTION(target.charAt(y - 1), y - 1, x - 1));
				trace("Up INSERTION");
				y--;
			// Else take the cell above and delete
			} else {
				ops.push(DELETION(source.charAt(x - 1), x - 1));
				trace("Left DELETION");
				x--;
			}
			
		}
		
		trace(ops);
		
		//Sure.sure(steps == ops.length);
		
		return ops;
	}
	
	public static inline function idx(x:Int, y:Int, w:Int, h:Int):Int {
		x = x.clamp(0, w - 1);
		y = y.clamp(0, h - 1);
		return x + y * w;
	}
}