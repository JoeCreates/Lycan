package lycan.constraint.frontend;

import haxe.ds.GenericStack;
import lycan.constraint.Constraint.RelationalOperator;
import lycan.constraint.Expression;
import lycan.constraint.Solver;
import lycan.constraint.Strength;
import lycan.constraint.Term;
import lycan.constraint.Variable;
import openfl.Vector;
import lycan.constraint.Symbolics.VariableSymbolics;
import lycan.constraint.Symbolics.ExpressionSymbolics;

// Runtime parser for strings -> constraints/expressions
class ConstraintParser {
	private static inline var relationalOperators:String = "-+/*^";
	private static inline var equalityOperator:String = "==";
	
	private static var pattern = new EReg("\\s*(.*?)\\s*(<=|==|>=|[GL]?EQ)\\s*(.*?)", "");
	
	public static function parseConstraint(constraintString:String, ?strengthString:String = "required", solver:Solver):Constraint {
		var matched:Bool = pattern.match(constraintString);
		
		if (!matched) {
			throw "Failed to parse " + constraintString;
		}
		
		var variable:Variable = solver.resolveVariable(pattern.matched(1));
		var relationalOperator:RelationalOperator = parseRelationalOperator(pattern.matched(2));
		var expression:Expression = resolveExpression(pattern.matched(3), solver);
		
		var strength:Float = parseStrength(strengthString);
		
		return new Constraint(VariableSymbolics.subtractExpression(variable, expression), relationalOperator, strength);		
	}
	
	private static function resolveExpression(expressionString:String, solver:Solver):Expression {
		var postFixExpression:Vector<String> = infixToPostfix(tokenizeExpression(expressionString));
		var expressionStack = new GenericStack<Expression>();
		
		for (expression in postFixExpression) {
			if (expression == "+") {
				expressionStack.add(ExpressionSymbolics.addExpression(expressionStack.pop(), expressionStack.pop()));
			} else if (expression == "-") {
				var a = expressionStack.pop();
				var b = expressionStack.pop();
				expressionStack.add(ExpressionSymbolics.subtractExpression(b, a));
			} else if (expression == "/") {
				var denominator = expressionStack.pop();
				var numerator = expressionStack.pop();
				expressionStack.add(ExpressionSymbolics.divideByExpression(numerator, denominator));
			} else if (expression == "*") {
				var a = expressionStack.pop();
				var b = expressionStack.pop();
				expressionStack.add(ExpressionSymbolics.multiplyByExpression(a, b));
			} else {
				var linearExpression:Expression = solver.resolveConstant(expression);
				if (linearExpression == null) {
					var term = new Vector<Term>();
					term.push(new Term(solver.resolveVariable(expression)));
					linearExpression = new Expression(term);
				}
				expressionStack.add(linearExpression);
			}
		}
		
		if (expressionStack.isEmpty()) {
			return null;
		}
		
		return expressionStack.pop();
	}
	
	private static function parseRelationalOperator(operatorString:String):RelationalOperator {
		return switch(StringTools.trim(operatorString)) {
			case RelationalOperator.EQ:
				RelationalOperator.EQ;
			case RelationalOperator.GE:
				RelationalOperator.GE;
			case RelationalOperator.LE:
				RelationalOperator.LE;
			default:
				throw "Failed to convert string " + operatorString + " to a relational operator";
		}
	}
	
	private static function parseStrength(strengthString:String):Float {
		var strength = Strength.required;
		
		if (strengthString == "required") {
			strength = Strength.required;
		} else if (strengthString == "strong") {
			strength = Strength.strong;
		} else if (strengthString == "medium") {
			strength = Strength.medium;
		} else if (strengthString == "weak") {
			strength = Strength.weak;
		}
		
		return strength;
	}
	
	private static function tokenizeExpression(expressionString:String):Vector<String> {
		var tokens = new Vector<String>();
		var builder:String = "";
		var i = 0;
		for (i in 0...expressionString.length) {
			var ch:String = expressionString.charAt(i);
			switch(ch) {
				case '+', '-', '*', '/', '(', ')':
					if (builder.length > 0) {
						tokens.push(ch);
						builder = "";
					}
					tokens.push(ch);
				case ' ':
				default:
					builder += ch;
			}
		}
		if (builder.length > 0) {
			tokens.push(builder);
		}
		return tokens;
	}
	
	private static function infixToPostfix(tokens:Vector<String>):Vector<String> {
		var s = new GenericStack<Int>();
		var postfix = new Vector<String>();
		
		for (token in tokens) {
			var c:String = token.charAt(0);
			var idx:Int = relationalOperators.indexOf(c);
			if (idx != -1 && token.length == 1) {
				if (s.isEmpty()) {
					s.add(idx);
				} else {
					while (!s.isEmpty()) {
						var prec2:Int = Std.int(s.first() / 2);
						var prec1:Int = Std.int(idx / 2);
						if (prec2 > prec1 || (prec2 == prec1 && c != "^")) {
							postfix.push(relationalOperators.charAt(s.pop()));
						} else {
							break;
						}
					}
					s.add(idx);
				}
			} else if (c == "(") {
				s.add( -2);
			} else if (c == ")") {
				while (s.first() != 2) {
					postfix.push(relationalOperators.charAt(s.pop()));
				}
				s.pop();
			} else {
				postfix.push(token);
			}
		}
		
		while (!s.isEmpty()) {
			postfix.push(relationalOperators.charAt(s.pop()));
		}
		
		return postfix;
	}
}