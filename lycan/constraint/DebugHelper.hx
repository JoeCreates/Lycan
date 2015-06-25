package lycan.constraint;

import lycan.constraint.Constraint.RelationalOperator;
import lycan.constraint.Solver.ConstraintMap;
import lycan.constraint.Solver.EditMap;
import lycan.constraint.Solver.RowMap;
import lycan.constraint.Solver.VarMap;
import openfl.Vector;

@:access(lycan.constraint.Solver)
class DebugHelper {
	public static inline function dumpSolverState(solver:Solver):Void {
		trace("Objective");
		printSpacer();
		dumpRow(solver.objective);
		printSpacer();
		trace("Tableau");
		printSpacer();
		dumpRows(solver.rows);
		printSpacer();
		trace("Infeasible");
		printSpacer();
		dumpSymbols(solver.infeasibleRows);
		printSpacer();
		trace("Variables");
		printSpacer();
		dumpVars(solver.vars);
		printSpacer();
		trace("Constraints");
		printSpacer();
		dumpConstraints(solver.constraints);
		printSpacer();
	}
	
	public static inline function dumpRows(rows:RowMap):Void {
		
	}
	
	public static inline function dumpSymbols(symbols:Vector<Symbol>):Void {
		
	}
	
	public static inline function dumpVars(vars:VarMap):Void {
		
	}
	
	public static inline function dumpConstraints(constraints:ConstraintMap):Void {
		
	}
	
	public static inline function dumpEdits(edits:EditMap):Void {
		
	}
	
	public static inline function dumpRow(row:Row):Void {
		
	}
	
	public static inline function dumpSymbol(symbol:Symbol):Void {
		trace(Std.string(symbol.type) + symbol.id);		
	}
	
	public static inline function dumpConstraint(constraint:Constraint):Void {
		for (term in constraint.expression.terms) {
			trace(term.coefficient + " * " + term.variable.name + " + ");
		}
		trace(constraint.expression.constant);
		
		switch(constraint.operator) {
			case RelationalOperator.LE:
				trace(" <= 0 ");
			case RelationalOperator.GE:
				trace(" >= 0 ");
			case RelationalOperator.EQ:
				trace(" == 0 ");
		}
		
		trace(" | strength = " + constraint.strength);
	}
	
	private static inline function printSpacer():Void {
		trace("\n ---------- \n");
	}
}