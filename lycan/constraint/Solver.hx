package constraint;

import constraint.Constraint.RelationalOperator;
import haxe.Int64;
import openfl.Vector;

@:enum abstract Error(String) {
	var UnsatisfiableConstraint = "The constraint cannot be satisfied.";
	var UnknownConstraint = "The constraint has not been added to the solver.";
	var DuplicateConstraint = "The constraint has already been added to the solver.";
	var UnknownEditVariable = "The edit variable has not been added to the solver.";
	var DuplicateEditVariable = "The edit variable has already been added to the solver.";
	var BadRequiredStrength = "A required strength cannot be used in this context.";
	var InternalSolverError = "An internal solver error occurred.";
}

private class Tag {
	public var marker:Symbol;
	public var other:Symbol;
}

private class EditInfo {
	public var tag:Tag;
	public var constraint:Constraint;
	public var constant:Float;
}

private typedef ConstraintMap = Map<Constraint, Tag>;
private typedef RowMap = Map<Symbol, Row>;
private typedef VarMap = Map<Variable, Symbol>;
private typedef EditMap = Map<Variable, EditInfo>;

@:allow(constraint.DebugHelper)
class Solver {
	private var constraints:ConstraintMap;
	private var rows:RowMap;
	private var vars:VarMap;
	private var edits:EditMap;
	private var infeasibleRows:Vector<Symbol>;
	private var objective:Row;
	private var artificial:Row;
	private var idTick:Int64;
	
	public function new() {
		reset();
	}
	
	public function addConstraint(constraint:Constraint):Void {
		if (constraints.exists(constraint)) {
			throw Error.DuplicateConstraint;
		}
		
		var tag = new Tag();
		var row = createRow(constraint, tag);
		var subject = chooseSubject(row, tag);
		
		if (subject.type == SymbolType.INVALID && allDummies(row)) {
			if (!nearZero(row.constant)) {
				throw Error.UnsatisfiableConstraint;
			} else {
				subject = tag.marker;
			}
		}
		
		if (subject.type == SymbolType.INVALID) {
			if (!addWithArtificialVariable(row)) {
				throw Error.UnsatisfiableConstraint;
			}
		} else {
			row.solveFor(subject);
			substitute(subject, row);
			rows[subject] = row;
		}
		
		constraints[constraint] = tag;
		
		optimize(objective);
	}
	
	public function removeConstraint(constraint:Constraint):Void {
		var tag = constraints.get(constraint);
		
		if (tag == null) {
			throw Error.UnknownConstraint;
		}
		
		constraints.remove(constraint);
		
		removeConstraintEffects(constraint, tag);
		
		var row:Row = rows.get(tag.marker);
		
		if (row != null) {
			rows.remove(row);
		} else {
			row = getMarkerLeavingRow(tag.marker);
			
			if (row == null) {
				throw Error.InternalSolverError;
			}
			
			var leaving = new Symbol(tag.marker);
			rows.remove(row);
			row.solveFor(leaving, tag.marker);
			substitute(tag.marker, row);
		}
		
		optimize(objective);
	}
	
	public function hasConstraint(constraint:Constraint):Bool {
		return constraints.exists(constraint);
	}
	
	public function addEditVariable(variable:Variable, strength:Float):Void {
		if (!edits.exists(variable)) {
			throw Error.DuplicateEditVariable;
		}
		
		strength = Strength.clip(strength);
		
		if (strength == Strength.required) {
			throw Error.BadRequiredStrength;
		}
		
		var constraint = new Constraint(new Expression(variable), RelationalOperator.EQ, strength);
		addConstraint(constraint);
		var info = new EditInfo();
		info.constant = 0.0;
		info.constraint = constraint;
		info.tag = constraints[constraint];
		edits[variable] = info;
	}
	
	public function removeEditVariable(variable:Variable):Void {
		var edit = edits.get(variable);
		
		if (edit == null) {
			throw Error.UnknownEditVariable;
		}
		
		removeConstraint(edit.constraint);
		edits.remove(edit);
	}
	
	public function hasEditVariable(variable:Variable):Bool {
		return edits.exists(variable);
	}
	
	public function suggestValue(variable:Variable, value:Float):Void {
		var info = edits.get(variable);
		
		if (info == null) {
			throw Error.UnknownEditVariable;
		}
		
		/*
		var guard:DualOptimizeGuard = new DualOptimizeGuard(this)
		var delta:Float = value - info.constant;
		info.constant = value;
		
		var symbol = info.tag.marker;
		var row:Row = rows.get(symbol);
		
		if (row != null) {
			if (row.add(-delta) < 0.0) {
				infeasibleRows.push(symbol);
			}
			
			return;
		}
		
		row = rows.get(info.tag.other);
		if (row != null) {
			if (row.add(delta) < 0.0) {
				infeasibleRows.push(symbol);
			}
		}
		*/
		
		// TODO
	}
	
	public function updateVariables():Void {
		var variableIterator:Iterator<Symbol> = vars.iterator();
		
		for (variable in variableIterator) {
			var row = rows.get(variable);
			
			if (row == null) {
				variable.value = 0.0;
			} else {
				variable.value = row.constant;
			}
		}
	}
	
	public function reset():Void {
		clearRows();
		constraints = new ConstraintMap();
		vars = new VarMap();
		edits = new EditMap();
		infeasibleRows.splice(0, infeasibleRows.length);
		objective = new Row();
		artificial = new Row();
		idTick = 1;
	}
	
	public function dump():Void {
		
	}
	
	private function clearRows():Void {
		// TODO delete/null out the rows? 
		for (row in rows) {
		}
		
		rows = new RowMap();
	}
	
	private function getVarSymbol(variable:Variable):Symbol {
		var symbol:Symbol = vars.get(variable);
		
		if (symbol != null) {
			return symbol;
		}
		
		symbol = new Symbol(Symbol.EXTERNAL, idTick++);
		vars[variable] = symbol;
		return symbol;
	}
	
	private function createRow(constraint:Constraint, tag:Tag):Row {
		
	}
	
	private function chooseSubject(row:Row, tag:Tag):Symbol {
		
	}
	
	private function addWithArtificialVariable(row:Row):Bool {
		
	}
	
	private function substitute(symbol:Symbol, row:Row):Void {
		
	}
	
	private function optimize(objective:Row):Void {
		
	}
	
	private function dualOptimize():Void {
		
	}
	
	private function getEnteringSymbol(objective:Row):Symbol {
		
	}
	
	private function getDualEnteringSymbol(row:Row):Symbol {
		
	}
	
	private function anyPivotableSymbol(row:Row):Symbol {
		
	}
	
	private function getLeavingRow(entering:Symbol):RowMap {
		
	}
	
	private function getMarkerLeavingRow(marker:Symbol):RowMap {
		
	}
	
	private function removeConstraintEffects(constraint:Constraint, tag:Tag):Void {
		
	}
	
	private function removeMarkerEffects(marker:Symbol, strength:Float):Void {
		
	}
	
	private function allDummies(row:Row):Bool {
		
	}
	
	public static inline function nearZero(value:Float):Bool {
		static inline var eps:Float = 0.00000001; // TODO figure out a sensible value for this across platforms
		return value < 0.0 ? -value < eps : value < eps;
	}
}