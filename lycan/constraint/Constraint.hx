package lycan.constraint;

@:enum abstract RelationalOperator(String) {
	var LE = "<=";
	var EQ = "==";
	var GE = ">=";
}

class Constraint {
	public var expression(get, null):Expression;
	public var operator(get, null):RelationalOperator;
	public var strength(get, null):Float;
	
	public inline function new(expression:Expression, operator:RelationalOperator, ?strength:Null<Float>) {
		Sure.sure(expression != null && operator != null);
		
		if (strength == null) {
			strength = Strength.required;
		}
		
		this.expression = reduce(expression);
		this.operator = operator;
		this.strength = Strength.clip(strength);
	}
	
	private function get_expression():Expression {
		return expression;
	}
	
	private function get_operator():RelationalOperator {
		return operator;
	}
	
	private function get_strength():Float {
		return strength;
	}
	
	private static function reduce(expr:Expression):Expression {
		Sure.sure(expr != null);
		
		var vars = new Map<Variable, Float>();
		
		for (term in expr.terms) {
			var value:Null<Float> = vars.get(term.variable);
			if (value == null) {
				value = 0.0;
			}
			vars.set(term.variable, value += term.coefficient);
		}
		
		var reducedTerms = new Array<Term>();
		for (variable in vars.keys()) {
			reducedTerms.push(new Term(variable, vars.get(variable)));
		}
		
		return new Expression(reducedTerms, expr.constant);
	}
}