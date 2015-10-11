package lycan.ai;

using lycan.util.IntExtensions;
using lycan.util.FloatExtensions;

// Fast incremental grid traversal algorithm based on http://www.cse.yorku.ca/~amana/research/grid.pdf
// Includes all tiles traversed by the line, with no narrow diagonals
class AmanatidesWoo {
	public static function traverse(x1:Float, y1:Float, x2:Float, y2:Float, tileWidth:Int, tileHeight:Int, maxSteps:Int):Array<{ x:Float, y:Float }> {
		Sure.sure(tileWidth > 0 && tileHeight > 0);
		
		if (x1 == x2 && y1 == y2) {
			return [ { x: x1, y: y1 } ];
		}
		
		var points:Array<{ x:Float, y:Float }> = [];
		
		// The edge case is where a coordinate of the ray origin is an integer value, and the corresponding part of the ray direction is negative
		x1 = edgeCase(x1);
		y1 = edgeCase(y1);
		
		var x:Int = Std.int(x1);
		var y:Int = Std.int(y1);
		var xEnd:Int = Std.int(x2);
		var yEnd:Int = Std.int(y2);
		
		var dx:Float = tileWidth / Math.abs(x2 - x1);
		var xStep:Int = Std.int((x2 - x1).sign()) * tileWidth;
		var xMax:Float = dx * (x1 / tileWidth).rfpart();
		var dy:Float = tileHeight / Math.abs(y2 - y1);
		var yStep:Int = Std.int((y2 - y1).sign()) * tileHeight;
		var yMax:Float = dy * (y1 / tileHeight).rfpart();
		
		var xReached:Bool = false;
		var yReached:Bool = false;
		
		var iterations:Int = 0;
		while (!(xReached && yReached) && iterations < maxSteps) {
			if (xMax < yMax) {
				x += xStep;
				xMax += dx;
			} else {
				y += yStep;
				yMax += dy;
			}
			
			if (xStep > 0.0) {
				if (x >= xEnd) {
					xReached = true;
				}
			} else if (x <= xEnd) {
				xReached = true;
			}
			
			if (yStep > 0) {
				if (y >= yEnd) {
					yReached = true;
				}
			} else if (y <= yEnd) {
				yReached = true;
			}
			
			points.push( { x: x, y: y } );
			iterations++;
		}
		
		return points;
	}
	
	private static inline function edgeCase(v:Float):Float {
		return v.fpart() == 0 ? v + 0.1 : v;
	}
}