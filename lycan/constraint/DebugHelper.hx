package constraint;

import openfl.Vector;

class DebugHelper {
	public static inline function dumpSolverState(solver:Solver):Void {
		trace("Objective");
		printSpacer();
		trace(dumpRow(solver.objective));
		printSpacer();
		trace("Tableau");
		printSpacer();
		trace(dumpRows(solver.rows));
		printSpacer();
		trace("Infeasible");
		printSpacer();
		trace(dumpRowMap(solver.infeasibleRows));
		printSpacer();
		trace("Variables");
		printSpacer();
		trace(dumpVars(solver.vars));
		printSpacer();
		trace("Constraints");
		printSpacer();
		trace(dumpConstraints(solver.constraints));
		printSpacer();
	}
	
	public static inline function dumpRows(rows:RowMap):Void {
		
	}
	
	public static inline function dumpSymbols(symbols:Vector<Symbol>):Void {
		
	}
	
	public static inline function dumpVars(vars:VarMap):Void {
		
	}
	
	public static inline function dumpConstraints(constraints:ConstantMap):Void {
		
	}
	
	public static inline function dumpEdits(edits:EditMap):Void {
		
	}
	
	public static inline function dumpRow(row:Row):Void {
		
	}
	
	public static inline function dumpSymbol(symbol:Symbol):Void {
		trace(Std.string(symbol.type) + symbol.id);		
	}
	
	public static inline function dumpConstraint(constraint:Constraint):Void {
		for (term in constraint.expression) {
			trace(term.coefficient + " * " + term.variable.name " + ";
		}
		trace(constraint.expression.constant);
		
		switch(constraint.operator) {
			case OP_LE:
				trace(" <= 0 ");
				break;
			case OP_GE:
				trace(" >= 0 ");
				break;
			case OP_EQ:
				trace(" == 0 ");
				break;
		}
		
		trace(" | strength = " constraint.strength);
	}
	
	private static inline function printSpacer():Void {
		trace("\n ---------- \n");
	}
}