package lycan.constraint;

import haxe.macro.Expr.Constant;
import openfl.Vector;
import lycan.constraint.Constraint.RelationalOperator;

// TODO look at @:op and @:commutative, can they be used for this kind of thing
class VariableSymbolics {
	inline public static function multiplyByFloat(variable:Variable, coefficient:Float):Term {
		return new Term(variable, coefficient);
	}
	
	inline public static function divideByFloat(variable:Variable, denominator:Float):Term {
		return multiplyByFloat(variable, 1.0 / denominator);
	}
	
	inline public static function negate(variable:Variable):Term {
		return multiplyByFloat(variable, -1.0);
	}
	
	inline public static function addExpression(variable:Variable, expression:Expression):Expression {
		return ExpressionSymbolics.addVariable(expression, variable);
	}
	
	inline public static function addTerm(variable:Variable, term:Term):Expression {
		return TermSymbolics.addVariable(term, variable);
	}
	
	inline public static function addVariable(first:Variable, second:Variable):Expression {
		return TermSymbolics.addVariable(new Term(first), second);
	}
	
	inline public static function addFloat(variable:Variable, constant:Float):Expression {
		return TermSymbolics.addFloat(new Term(variable), constant);
	}
	
	inline public static function subtractExpression(variable:Variable, expression:Expression):Expression {
		return addExpression(variable, ExpressionSymbolics.negate(expression));
	}
	
	inline public static function subtractTerm(variable:Variable, term:Term):Expression {
		return addTerm(variable, TermSymbolics.negate(term));
	}
	
	inline public static function subtractVariable(first:Variable, second:Variable):Expression {
		return addTerm(first, negate(second));
	}
	
	inline public static function subtractFloat(variable:Variable, constant:Float):Expression {
		return addFloat(variable, -constant);
	}
	
	inline public static function equalsExpression(variable:Variable, expression:Expression):Constraint {
		return ExpressionSymbolics.equalsVariable(expression, variable);
	}
	
	inline public static function equalsTerm(variable:Variable, term:Term):Constraint {
		return TermSymbolics.equalsVariable(term, variable);
	}
	
	inline public static function equalsVariable(first:Variable, second:Variable):Constraint {
		return TermSymbolics.equalsVariable(new Term(first), second);
	}
	
	inline public static function equalsFloat(variable:Variable, constant:Float):Constraint {
		return TermSymbolics.equalsFloat(new Term(variable), constant);
	}
	
	inline public static function lessThanOrEqualToExpression(variable:Variable, expression:Expression):Constraint {
		return ExpressionSymbolics.lessThanOrEqualToVariable(expression, variable);
	}
	
	inline public static function lessThanOrEqualToTerm(variable:Variable, term:Term):Constraint {
		return TermSymbolics.lessThanOrEqualToVariable(term, variable);
	}
	
	inline public static function lessThanOrEqualToVariable(first:Variable, second:Variable):Constraint {
		return TermSymbolics.lessThanOrEqualToVariable(new Term(first), second);
	}
	
	inline public static function lessThanOrEqualToFloat(variable:Variable, constant:Float):Constraint {
		return TermSymbolics.lessThanOrEqualToFloat(new Term(variable), constant);
	}
	
	inline public static function greaterThanOrEqualToExpression(variable:Variable, expression:Expression):Constraint {
		return ExpressionSymbolics.greaterThanOrEqualToVariable(expression, variable);
	}
	
	inline public static function greaterThanOrEqualToTerm(variable:Variable, term:Term):Constraint {
		return TermSymbolics.greaterThanOrEqualToVariable(term, variable);
	}
	
	inline public static function greaterThanOrEqualToVariable(first:Variable, second:Variable):Constraint {
		return TermSymbolics.greaterThanOrEqualToVariable(new Term(first), second);
	}
	
	inline public static function greaterThanOrEqualToFloat(variable:Variable, constant:Float):Constraint {
		return TermSymbolics.greaterThanOrEqualToFloat(new Term(variable), constant);
	}
}

class TermSymbolics {
	inline public static function multiplyByFloat(term:Term, coefficient:Float):Term { 
		return new Term(term.variable, term.coefficient * coefficient);
	}
	
	inline public static function divideByFloat(term:Term, denominator:Float):Term {
		return multiplyByFloat(term, (1.0 / denominator));
	}
	
	inline public static function negate(term:Term):Term {
		return multiplyByFloat(term, -1.0);
	}
	
	inline public static function addExpression(term:Term, expression:Expression):Expression {
		return ExpressionSymbolics.addTerm(expression, term);
	}
	
	inline public static function addTerm(first:Term, second:Term):Expression {
		var terms = new Vector<Term>();
		terms.push(first);
		terms.push(second);
		return new Expression(terms);
	}
	
	inline public static function addVariable(term:Term, variable:Variable):Expression {
		return addTerm(term, new Term(variable));
	}
	
	inline public static function addFloat(term:Term, constant:Float):Expression {
		var terms = new Vector<Term>();
		terms.push(term);
		return new Expression(terms, constant);
	}
	
	inline public static function subtractExpression(term:Term, expression:Expression):Expression {
		return ExpressionSymbolics.addTerm(ExpressionSymbolics.negate(expression), term);
	}
	
	inline public static function subtractTerm(first:Term, second:Term):Expression {
		return addTerm(first, negate(second));
	}
	
	inline public static function subtractVariable(term:Term, variable:Variable):Expression {
		return addTerm(term, VariableSymbolics.negate(variable));
	}
	
	inline public static function subtractFloat(term:Term, constant:Float):Expression {
		return addFloat(term, -constant);
	}
	
	inline public static function equalsExpression(term:Term, expression:Expression):Constraint {
		return ExpressionSymbolics.equalsTerm(expression, term);
	}
	
	inline public static function equalsTerm(first:Term, second:Term):Constraint {
		var terms = new Vector<Term>();
		terms.push(first);
		return ExpressionSymbolics.equalsTerm(new Expression(terms), second);
	}
	
	inline public static function equalsVariable(term:Term, variable:Variable):Constraint {
		var terms = new Vector<Term>();
		terms.push(term);
		return ExpressionSymbolics.equalsVariable(new Expression(terms), variable);
	}
	
	inline public static function equalsFloat(term:Term, constant:Float):Constraint {
		var terms = new Vector<Term>();
		terms.push(term);
		return ExpressionSymbolics.equalsFloat(new Expression(terms), constant);
	}
	
	inline public static function lessThanOrEqualToExpression(term:Term, expression:Expression):Constraint {
		return ExpressionSymbolics.lessThanOrEqualToTerm(expression, term);
	}
	
	inline public static function lessThanOrEqualToTerm(first:Term, second:Term):Constraint {
		var terms = new Vector<Term>();
		terms.push(first);
		return ExpressionSymbolics.lessThanOrEqualToTerm(new Expression(terms), second);
	}
	
	inline public static function lessThanOrEqualToVariable(term:Term, variable:Variable):Constraint {
		var terms = new Vector<Term>();
		terms.push(term);
		return ExpressionSymbolics.lessThanOrEqualToVariable(new Expression(terms), variable);
	}
	
	inline public static function lessThanOrEqualToFloat(term:Term, constant:Float):Constraint {
		var terms = new Vector<Term>();
		terms.push(term);
		return ExpressionSymbolics.lessThanOrEqualToFloat(new Expression(terms), constant);
	}
	
	inline public static function greaterThanOrEqualToExpression(term:Term, expression:Expression):Constraint {
		return ExpressionSymbolics.greaterThanOrEqualToTerm(expression, term);
	}
	
	inline public static function greaterThanOrEqualToTerm(first:Term, second:Term):Constraint {
		var terms = new Vector<Term>();
		terms.push(first);
		return ExpressionSymbolics.greaterThanOrEqualToTerm(new Expression(terms), second);
	}
	
	inline public static function greaterThanOrEqualToVariable(term:Term, variable:Variable):Constraint {
		var terms = new Vector<Term>();
		terms.push(term);
		return ExpressionSymbolics.greaterThanOrEqualToVariable(new Expression(terms), variable);
	}
	
	inline public static function greaterThanOrEqualToFloat(term:Term, constant:Float):Constraint {
		var terms = new Vector<Term>();
		terms.push(term);
		return ExpressionSymbolics.greaterThanOrEqualToFloat(new Expression(terms), constant);
	}
}

class ExpressionSymbolics {
	inline public static function multiplyByFloat(expression:Expression, coefficient:Float):Expression {
		var terms = new Vector<Term>();
		for (term in expression.terms) {
			terms.push(TermSymbolics.multiplyByFloat(term, coefficient));
		}
		return new Expression(terms, expression.constant * coefficient);
	}
	
	inline public static function multiplyByExpression(expression1:Expression, expression2:Expression):Expression {
		if (expression1.isConstant()) {
			return FloatSymbolics.multiplyByExpression(expression1.constant, expression2);
		} else if (expression2.isConstant()) {
			return FloatSymbolics.multiplyByExpression(expression2.constant, expression1);
		} else {
			throw "Cannot multiply two non-constant expressions";
		}
	}
	
	inline public static function divideByFloat(expression:Expression, denominator:Float):Expression {
		return multiplyByFloat(expression, (1.0 / denominator));
	}
	
	inline public static function divideByExpression(expression1:Expression, expression2:Expression):Expression {
		if (expression2.isConstant()) {
			return divideByFloat(expression1, expression2.constant);
		} else {
			throw "Cannot divide with non linear expression";
		}
	}
	
	inline public static function negate(expression:Expression):Expression {
		return multiplyByFloat(expression, -1.0);
	}
	
	inline public static function addExpression(first:Expression, second:Expression):Expression {
		var terms = new Vector<Term>();
		
		if(first.terms != null) {
			terms.concat(first.terms);
		}
		
		if(second.terms != null) {
			terms.concat(second.terms);
		}
		
		return new Expression(terms, first.constant + second.constant);
	}
	
	inline public static function addTerm(expression:Expression, term:Term):Expression {
		var terms = new Vector<Term>();
		
		if(expression.terms != null) {
			terms.concat(expression.terms);
		}
		
		terms.push(term);
		
		return new Expression(terms, expression.constant);
	}
	
	inline public static function addVariable(expression:Expression, variable:Variable):Expression {
		return addTerm(expression, new Term(variable));
	}
	
	inline public static function addFloat(expression:Expression, constant:Float):Expression {
		return new Expression(expression.terms, expression.constant + constant);
	}
	
	inline public static function subtractExpression(first:Expression, second:Expression):Expression {
		return addExpression(first, negate(second));
	}
	
	inline public static function subtractTerm(expression:Expression, term:Term):Expression {
		return addTerm(expression, TermSymbolics.negate(term));
	}
	
	inline public static function subtractVariable(expression:Expression, variable:Variable):Expression {
		return addTerm(expression, VariableSymbolics.negate(variable));
	}
	
	inline public static function subtractFloat(expression:Expression, constant:Float):Expression {
		return addFloat(expression, -constant);
	}
	
	inline public static function equalsExpression(first:Expression, second:Expression):Constraint {
		return new Constraint(subtractExpression(first, second), RelationalOperator.EQ);
	}
	
	inline public static function equalsTerm(expression:Expression, term:Term):Constraint {
		var terms = new Vector<Term>();
		terms.push(term);
		return equalsExpression(expression, new Expression(terms));
	}
	
	inline public static function equalsVariable(expression:Expression, variable:Variable):Constraint {
		return equalsTerm(expression, new Term(variable));
	}
	
	inline public static function equalsFloat(expression:Expression, constant:Float):Constraint {
		return equalsExpression(expression, new Expression(new Vector<Term>(), constant));
	}
	
	inline public static function lessThanOrEqualToExpression(first:Expression, second:Expression):Constraint {
		return new Constraint(subtractExpression(first, second), RelationalOperator.LE);
	}
	
	inline public static function lessThanOrEqualToTerm(expression:Expression, term:Term):Constraint {
		var terms = new Vector<Term>();
		terms.push(term);
		return lessThanOrEqualToExpression(expression, new Expression(terms));
	}
	
	inline public static function lessThanOrEqualToVariable(expression:Expression, variable:Variable):Constraint {
		return lessThanOrEqualToTerm(expression, new Term(variable));
	}
	
	inline public static function lessThanOrEqualToFloat(expression:Expression, constant:Float):Constraint {
		return lessThanOrEqualToExpression(expression, new Expression(new Vector<Term>(), constant));
	}
	
	inline public static function greaterThanOrEqualToExpression(first:Expression, second:Expression):Constraint {
		return new Constraint(subtractExpression(first, second), RelationalOperator.GE);
	}
	
	inline public static function greaterThanOrEqualToTerm(expression:Expression, term:Term):Constraint {
		var terms = new Vector<Term>();
		terms.push(term);
		return greaterThanOrEqualToExpression(expression, new Expression(terms));
	}
	
	inline public static function greaterThanOrEqualToVariable(expression:Expression, variable:Variable):Constraint {
		return greaterThanOrEqualToTerm(expression, new Term(variable));
	}
	
	inline public static function greaterThanOrEqualToFloat(expression:Expression, constant:Float):Constraint {
		return greaterThanOrEqualToExpression(expression, new Expression(new Vector<Term>(), constant));
	}
}

class FloatSymbolics {
	inline public static function multiplyByExpression(coefficient:Float, expression:Expression):Expression {
		return ExpressionSymbolics.multiplyByFloat(expression, coefficient);
	}
	
	inline public static function multiplyByTerm(coefficient:Float, term:Term):Term {
		return TermSymbolics.multiplyByFloat(term, coefficient);
	}
	
	inline public static function multiplyByVariable(coefficient:Float, variable:Variable):Term {
		return VariableSymbolics.multiplyByFloat(variable, coefficient);
	}
	
	inline public static function equalsExpression(constant:Float, expression:Expression):Constraint {
		return ExpressionSymbolics.equalsFloat(expression, constant);
	}
	
	inline public static function equalsTerm(constant:Float, term:Term):Constraint {
		return TermSymbolics.equalsFloat(term, constant);
	}
	
	inline public static function equalsVariable(constant:Float, variable:Variable):Constraint {
		return VariableSymbolics.equalsFloat(variable, constant);
	}
	
	inline public static function lessThanOrEqualToExpression(constant:Float, expression:Expression):Constraint {
		return ExpressionSymbolics.lessThanOrEqualToFloat(expression, constant);
	}
	
	inline public static function lessThanOrEqualToTerm(constant:Float, term:Term):Constraint {
		return TermSymbolics.lessThanOrEqualToFloat(term, constant);
	}
	
	inline public static function lessThanOrEqualToVariable(constant:Float, variable:Variable):Constraint {
		return VariableSymbolics.lessThanOrEqualToFloat(variable, constant);
	}
	
	inline public static function greaterThanOrEqualToExpression(constant:Float, expression:Expression):Constraint {
		return ExpressionSymbolics.greaterThanOrEqualToFloat(expression, constant);
	}
	
	inline public static function greaterThanOrEqualToTerm(constant:Float, term:Term):Constraint {
		return TermSymbolics.greaterThanOrEqualToFloat(term, constant);
	}
	
	inline public static function greaterThanOrEqualToVariable(constant:Float, variable:Variable):Constraint {
		return VariableSymbolics.greaterThanOrEqualToFloat(variable, constant);
	}
}

class Symbolics {
	// TODO expression strength
}