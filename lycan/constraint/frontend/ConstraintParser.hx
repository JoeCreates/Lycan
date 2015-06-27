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

// Adapted from Alex Birkett's kiwi-java port: https://github.com/alexbirkett/kiwi-java
// Runtime parser for strings -> Kiwi constraints
class ConstraintParser {
	private static inline var relationalOperators:String = "-+/*^";
	private static var pattern = new EReg("\\s*(.*?)\\s*(<=|==|>=)\\s*(.*?$)", "i");
	
	public static function parseConstraint(constraintString:String, ?strengthString:String = "required", resolver:Resolver):Constraint {
		var matched:Bool = pattern.match(constraintString);
		
		if (!matched) {
			throw "Failed to parse " + constraintString;
		}
		
		var variable:Variable = resolver.resolveVariable(StringTools.trim(pattern.matched(1)));
		var relationalOperator:RelationalOperator = parseEqualityOperator(StringTools.trim(pattern.matched(2)));
		var expression:Expression = resolveExpression(StringTools.trim(pattern.matched(3)), resolver);
		var strength:Float = parseStrength(strengthString);
		
		return new Constraint(VariableSymbolics.subtractExpression(variable, expression), relationalOperator, strength);		
	}
	
	private static function resolveExpression(expressionString:String, resolver:Resolver):Expression {
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
				var linearExpression:Expression = resolver.resolveConstant(StringTools.trim(expression));
				if (linearExpression == null) {
					var term = new Vector<Term>();
					term.push(new Term(resolver.resolveVariable(StringTools.trim(expression))));
					linearExpression = new Expression(term);
				}
				expressionStack.add(linearExpression);
			}
		}
		
		Sure.sure(!expressionStack.isEmpty());
		return expressionStack.pop();
	}
	
	private static function parseEqualityOperator(operatorString:String):RelationalOperator {
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
		Sure.sure(strengthString != null);
		
		var strength:Float = 0;
		
		if (strengthString == "required") {
			strength = Strength.required;
		} else if (strengthString == "strong") {
			strength = Strength.strong;
		} else if (strengthString == "medium") {
			strength = Strength.medium;
		} else if (strengthString == "weak") {
			strength = Strength.weak;
		} else {
			strength = Std.parseFloat(strengthString);
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
						tokens.push(builder);
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