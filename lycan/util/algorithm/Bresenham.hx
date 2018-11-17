package lycan.util.algorithm;

// Derived from http://deepnight.net/bresenham-magic-raycasting-line-of-sight-pathfinding/
// Returns a raster representation of a line between two points. Lines can have narrow diagonals.
class Bresenham {
	public static function getLine(x0:Int, y0:Int, x1:Int, y1:Int): Array<{x:Int, y:Int}> {     
		
		var points = [];
		var tmp:Int;
		var swapXY:Bool = Math.abs(y1 - y0) > Math.abs(x1 - x0);
		if (swapXY) {
			tmp = x0; x0 = y0; y0 = tmp;
			tmp = x1; x1 = y1; y1 = tmp;
		}
		if (x0 > x1) {
			tmp = x0; x0 = x1; x1 = tmp;
			tmp = y0; y0 = y1; y1 = tmp;
		}
		var dx:Int = x1 - x0;
		var dy:Int = Math.floor(Math.abs(y1 - y0));
		var error:Int = Math.floor(dx / 2);
		var y:Int = y0;
		var yStep:Int = (y0 < y1) ? 1 : -1;
		if (swapXY) {
			for (x in x0...x1 + 1) {
				points.push({x: y, y: x});
				error -= dy;
				if (error < 0) {
					y = y + yStep;
					error = error + dx;
				}
			}
		} else {
			for (x in x0...x1 + 1) {
				points.push({x: x, y: y});
				error -= dy;
				if (error < 0) {
					y = y + yStep;
					error = error + dx;
				}
			}
		}
		
		return points;
	}
}