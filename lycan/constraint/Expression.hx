package constraint;
import openfl.Vector;

abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}
private typedef TermParameter = OneOfTwo<Term, Vector<Term>>;

class Expression {
	public var terms(get, null):Vector<Term>;
	public var constant(get, null):Float;
	public var value(get, never):Float;
	
	public function new(?terms:TermParameter, ?constant:Float = 0.0) {
		this.terms = terms;
		this.constant = constant;
	}
	
	private function get_constant():Float {
		return constant;
	}
	
	private function get_terms():Vector<Term> {
		return terms;
	}
	
	private function get_value():Float {
		var result = constant;
		for (term in terms) {
			result += term.value;
		}
		return result;
	}
}