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
		constant += value;
		return constant;
	}
	
	public function insertSymbol(symbol:Symbol, ?coefficient:Float = 1.0):Void {
		Sure.sure(symbol != null);
		
		var existingCoefficient:Null<Float> = cells.get(symbol);
		if (existingCoefficient != null) {
			coefficient = existingCoefficient; // TODO = or += ... kiwi-java is =
		}
		
		if (Util.nearZero(coefficient)) {
			cells.remove(symbol);
		} else {
			cells.set(symbol, coefficient);
		}
	}
	
	public function insertRow(row:Row, ?coefficient:Float = 1.0):Void {
		Sure.sure(row != null);
		
		constant += row.constant * coefficient;
		
		for (key in row.cells.keys()) {
			var coeff:Float = row.cells.get(key) * coefficient;
			insertSymbol(key, coeff);
		}
	}
	
	public function remove(symbol:Symbol):Void {
		cells.remove(symbol);
	}
	
	public function reverseSign():Void {
		constant = -constant;
		
		var newCells = new CellMap(); // TODO is this really necessary?
		for (key in cells.keys()) {
			var value:Float = -cells.get(key);
			newCells.set(key, value);
		}
		
		this.cells = newCells;
	}
	
	public function solveForSymbol(symbol:Symbol):Void {
		Sure.sure(symbol != null);
		
		var coefficient:Float = -1.0 / cells.get(symbol);
		cells.remove(symbol);
		constant *= coefficient;
		for (cell in cells) {
			cell *= coefficient;
		}
	}
	
	public function solveForSymbols(lhs:Symbol, rhs:Symbol):Void {
		Sure.sure(lhs != null && rhs != null);
		
		insertSymbol(lhs, -1.0);
		solveForSymbol(rhs);
	}
	
	public function coefficientFor(symbol:Symbol):Float {
		Sure.sure(symbol != null);
		
		var cell:Null<Float> = cells.get(symbol);
		if (cell == null) {
			return 0;
		} else {
			return cell;
		}
	}
	
	public function substitute(symbol:Symbol, row:Row):Void {
		Sure.sure(symbol != null && row != null);
		
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