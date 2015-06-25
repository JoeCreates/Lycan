package constraint;

class Row {
	private var constant(get, null):Float;
	
	public function new(?constant:Float = 0.0) {
		this.constant = constant;
	}
	
	public function get_constant():Float {
		return constant;
	}
	
	public function add(value:Float):Float {
		constant += value;
		return constant;
	}
	
	public function insert(symbol:Symbol, ?coefficient:Float = 1.0):Void {
		
	}
	
	public function remove(symbol:Symbol):Void {
		
	}
	
	public function reverseSign():Void {
		
	}
	
	public function solveFor(symbol:Symbol):Void {
		
	}
	
	public function solveFor(lhs:Symbol, rhs:Symbol):Void {
		
	}
	
	public function coefficientFor(symbol:Symbol):Float {
		
	}
	
	public function substitute(symbol:Symbol, row:Row):Void {
		
	}
}