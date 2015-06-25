package constraint;
import haxe.ds.HashMap;
import haxe.ds.Vector;
import haxe.macro.Expr.Access;

@:enum abstract RelationalOperator(Int) {
	var LE = -1;
	var EQ = 0;
	var GE = 1;
}

class Constraint {
	public var expression(get, null):Expression;
	public var operator(get, null):RelationalOperator;
	public var strength(get, null):Float;
	
	public function new(expression:Expression, operator:RelationalOperator, strength:Float = Strength.Required) {
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
		var vars = new HashMap<Variable, Float>();
		
		for (term in expr.terms) {
			var variable = vars.get(term.variable);
			if (variable != null) {
				variable.value += term.coefficient;
			} else {
				vars.set(variable, term.coefficient);
			}
		}
		
		var termIterator = vars.keys();
		
		var reducedTerms = new Vector<Term>();
		for (term in termIterator) {
			reducedTerms.push(term);
		}
		
		return new Expression(reducedTerms, expr.constant);
	}
}