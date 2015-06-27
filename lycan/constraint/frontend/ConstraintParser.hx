package lycan.constraint.frontend;

import lycan.constraint.Constraint.RelationalOperator;
import lycan.constraint.Expression;
import lycan.constraint.Solver;
import lycan.constraint.Strength;
import lycan.constraint.Variable;
import openfl.Vector;

// Runtime parser for strings -> constraints/expressions
class ConstraintParser {
	private static inline var relationalOperators:String = "-+/*^";
	private static inline var equalityOperator:String = "==";
	
	private static var pattern = ~/\\s*(.*?)\\s*(<=|==|>=|[GL]?EQ)\\s*(.*?)\\s*(!(required|strong|medium|weak))?/;
	
	private static function parseConstraint(constraintString:String, ?strengthString:String = "required", variableResolver:Solver):Constraint {
		pattern.match(constraintString);
		
		// TODO postfix -> infix
		// TODO
		// Get variable
		// Get operator
		// Resolve expression
		// Resolve strength
		
		throw "Failed to parse " + constraintString;
	}
	
	private static function resolveExpression(expressionString:String, solver:Solver):Expression {
		throw "Failed to parse " + expressionString;
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
}