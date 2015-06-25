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
	
	public static inline function dumpVars(vars:VarMap):Void {
		
	}
	
	public static inline function dumpSymbols(symbols:Vector<Symbol>):Void {
		
	}
	
	public static inline function dumpConstraints(constraints:ConstantMap):Void {
		
	}
	
	public static inline function dumpEdits(edits:EditMap):Void {
		
	}
	
	public static inline function dumpRow(row:Row):Void {
		
	}
	
	public static inline function dumpSymbol(symbol:Symbol):Void {
		
	}
	
	public static inline function dumpConstraint(constraint:Constraint):Void {
		
	}
	
	private static inline function printSpacer():Void {
		trace("\n ---------- \n");
	}
}