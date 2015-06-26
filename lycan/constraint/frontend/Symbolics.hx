package lycan.constraint.frontend;

class Symbolics {
	// TODO need a nice way to handle this without overloading available
	
	inline public static function mul(variable:Variable, coefficient:Float):Term {
		return new Term(variable, coefficient);
	}
	
	inline public static function div(variable:Variable, denominator:Float):Term {
		return mul(variable, 1.0 / denominator);
	}
	
	inline public static function sub(variable:Variable):Term {
		return mul(variable, -1.0);
	}
}