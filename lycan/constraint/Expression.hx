package lycan.constraint;

import openfl.Vector;

class Expression {
	public var terms(get, null):Vector<Term>;
	public var constant(get, null):Float;
	
	public function new(?terms:Vector<Term>, constant:Float = 0.0) {
		if(terms == null) {
			terms = new Vector<Term>();
		}
		this.terms = terms;
		this.constant = constant;
	}
	
	private function get_terms():Vector<Term> {
		return terms;
	}
	
	private function get_constant():Float {
		return constant;
	}
	
	public function value():Float {
		var result = constant;
		for (term in terms) {
			result += term.value();
		}
		return result;
	}
	
	public function isConstant():Bool {
		return terms.length == 0;
	}
}