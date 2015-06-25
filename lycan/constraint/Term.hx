package constraint;

class Term {
	private var variable:Variable;
	private var coefficient:Float;
	
	public function new(variable:Variable, ?coefficient:Float = 1.0) {
		this.variable = variable;
		this.coefficient = coefficient;
	}
	
	public function value():Float {
		return variable.value() * coefficient;
	}
}