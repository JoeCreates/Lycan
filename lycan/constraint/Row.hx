package lycan.constraint;

typedef CellMap = Map<Symbol, Float>;

class Row {
	public var cells(get, null):CellMap = new CellMap();
	public var constant(get, null):Float;
	
	public function new(constant:Float = 0.0) {
		this.constant = constant;
	}
	
	public function deepCopy():Row {
		var row = new Row();
		row.constant = this.constant;
		for (key in cells.keys()) {
			row.cells.set(key, cells.get(key));
		}
		return row;
	}
	
	public function add(value:Float):Float {
		return constant += value;
	}
	
	public function insertSymbol(symbol:Symbol, ?coefficient:Float = 1.0):Void {
		var existingCoefficient:Null<Float> = cells.get(symbol);
		if (existingCoefficient != null) {
			coefficient += existingCoefficient;
		}
		
		if (Util.nearZero(coefficient)) {
			cells.remove(symbol);
		} else {
			cells.set(symbol, coefficient);
		}
	}
	
	public function insertRow(row:Row, ?coefficient:Float = 0.0):Void {
		// TODO java kiwi and original kiwi differ here
		constant += row.constant * coefficient;
		
		for (key in row.cells.keys()) {
			var coeff:Float = row.cells.get(key) * coefficient;
			insertSymbol(key, coeff);
		}
	}
	
	public function remove(symbol:Symbol):Void {
		var removed = cells.remove(symbol);
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
		solveForSymbol(rhs);
	}
	
	public function coefficientFor(symbol:Symbol):Float {
		var cell:Null<Float> = cells.get(symbol);
		if (cell == null) {
			return 0;
		} else {
			return cell;
		}
	}
	
	public function substitute(symbol:Symbol, row:Row):Void {
		var cell:Null<Float> = cells.get(symbol);
		if (cell != null) {
			var coefficient:Float = cell;
			cells.remove(symbol);
			insertRow(row, coefficient);
		}
	}
	
	private function get_cells():CellMap {
		return cells;
	}
	
	private function get_constant():Float {
		return constant;
	}
}