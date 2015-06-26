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
		trace("Tableau");
		printSpacer();
		dumpRows(solver.rows);
		trace("Infeasible");
		printSpacer();
		dumpSymbols(solver.infeasibleRows);
		trace("Variables");
		printSpacer();
		dumpVars(solver.vars);
		trace("Constraints");
		printSpacer();
		dumpConstraints(solver.constraints);
	}
	
	public static inline function dumpRows(rows:RowMap):Void {
		for (key in rows.keys()) {
			dumpSymbol(key);
			trace(" | ");
			dumpRow(rows.get(key));
		}
	}
	
	public static inline function dumpSymbols(symbols:Vector<Symbol>):Void {
		for (symbol in symbols) {
			dumpSymbol(symbol);
			trace("\n");
		}
	}
	
	public static inline function dumpVars(vars:VarMap):Void {
		for (key in vars.keys()) {
			trace(key.name + " = ");
			dumpSymbol(vars.get(key));
			trace("\n");
		}
	}
	
	public static inline function dumpConstraints(constraints:ConstraintMap):Void {
		for (key in constraints.keys()) {
			dumpConstraint(key);
		}
	}
	
	public static inline function dumpEdits(edits:EditMap):Void {
		for (key in edits.keys()) {
			trace(key.name);
			trace("\n");
		}
	}
	
	public static inline function dumpRow(row:Row):Void {
		trace(row.constant);
		for (key in row.cells.keys()) {
			trace(" + " + row.cells.get(key) + " * ");
			dumpSymbol(key);
		}
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