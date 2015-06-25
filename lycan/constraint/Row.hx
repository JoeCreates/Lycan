package constraint;

typedef CellMap = Map<Symbol, Float>;

class Row {
	public var constant(get, null):Float;
	public var cells(get, null):CellMap;
	
	public function new(?constant:Float = 0.0) {
		this.cells = new CellMap();
		this.constant = constant;
	}
	
	public function add(value:Float):Float {
		return constant += value;
	}
	
	public function insertSymbol(symbol:Symbol, ?coefficient:Float = 1.0):Void {
		var cell = cells.get(symbol);
		
		if (cell == null) {
			cells.set(symbol, coefficient);
		} else {
			if (Util.nearZero(cells.get(symbol) += coefficient)) {
				cells.remove(symbol);
			}
		}
	}
	
	public function insertRow(row:Row, ?coefficient:Float = 1.0):Void {
		constant += row.constant * coefficient;
		
		var keys:Iterator<Symbol> = row.cells.keys();
		for (key in keys) {
			var cell:Float = cells.get(key);
			if (cell != null) {
				var coeff:Float = cell * coefficient;
				if (cell == null) {
					cells.set(key, coefficient);
				} else {
					if (Util.nearZero(cells.get(key) += coeff)) {
						cells.remove(key);
					}
				}
			}
		}
	}
	
	public function remove(symbol:Symbol):Void {
		var removed = cells.remove(symbol);
		Sure.sure(removed);
	}
	
	public function reverseSign():Void {
		constant = -constant;
		
		for (cell in cells) {
			cell = -cell;
		}
	}
	
	public function solveForSymbol(symbol:Symbol):Void {
		var coefficient:Float = -1.0 / cells.get(symbol);
		var removed = cells.remove(symbol);
		Sure.sure(removed);
		constant *= coefficient;
		for (cell in cells) {
			cell *= coefficient;
		}
	}
	
	public function solveForSymbols(lhs:Symbol, rhs:Symbol):Void {
		insertSymbol(lhs, -1.0);
		solveFor(rhs);
	}
	
	public function coefficientFor(symbol:Symbol):Float {
		var cell = cells.get(symbol);
		if (cell == null) {
			return 0;
		}
		return cell;
	}
	
	public function substitute(symbol:Symbol, row:Row):Void {
		var cell = cells.find(symbol);
		if (cell != null) {
			var coefficient:Float = cell;
			cells.remove(cell);
			insertRow(row, coefficient);
		}
	}
	
	private function get_constant():Float {
		return constant;
	}
	
	private function get_cells():CellMap {
		return cells;
	}
}