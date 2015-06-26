package lycan.constraint.frontend;

import lycan.constraint.Constraint;
import lycan.constraint.Constraint.RelationalOperator;

// TODO using the constraint solver directly is far too verbose, so have helpers to use strings to specify constraints etc e.g. "x1 < 200; x2 > 300;" TODO: port/copy over something like enaml and haxeui's xml stuff
class Helpers {
	public static inline function parseConstraint(constraint:String):Constraint {
		// TODO convert string to constraint
	}
	
	private static inline function parseRelationalOperator(op:String):RelationalOperator {
		return switch(StringTools.trim(op)) {
			case RelationalOperator.EQ:
				RelationalOperator.EQ;
			case RelationalOperator.GE:
				RelationalOperator.GE;
			case RelationalOperator.LE:
				RelationalOperator.LE;
			default:
				throw "Failed to convert string " + op + " to a relational operator";
		}
	}
}