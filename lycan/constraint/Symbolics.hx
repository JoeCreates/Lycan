package lycan.constraint;

class Symbolics {
	// Variable multiply, divide, and unary invert
	inline public static function vmul(variable:Variable, coefficient:Float):Term {
		return new Term(variable, coefficient);
	}
	
	inline public static function vdiv(variable:Variable, denominator:Float):Term {
		return vmul(variable, 1.0 / denominator);
	}
	
	inline public static function vneg(variable:Variable):Term {
		return vmul(variable, -1.0);
	}
	
	// Term multiply, divide, and unary invert
	inline public static function tmul(term:Term, coefficient:Float):Term { 
		return new Term(term.variable, term.coefficient * coefficient);
	}
	
	inline public static function tdiv(term:Term, denominator:Float):Term {
		return tmul(term, (1.0 / denominator));
	}
	
	inline public static function tneg(term:Term):Term {
		return tmul(term, -1.0);
	}
	
	// TODO https://github.com/alexbirkett/kiwi-java/blob/master/src/main/java/no/birkett/kiwi/Symbolics.java
	
	// Expression multiply, divide, and unary invert
	
	// Expression add and subtract
	
	// Term add and subtract
	
	// Variable add and subtract
	
	// Float add and subtract
	
	// Expression relations
	// TODO inline public static function e
	
	// Term relations
	
	// Variable relations
	
	// Float relations
	
	// Constraint strength modifier
}