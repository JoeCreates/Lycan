package constraint;

import constraint.Constraint.RelationalOperator;
import haxe.Int64;
import openfl.Vector;

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
	
	public function reset():Void {
		rows = new RowMap();
		constraints = new ConstraintMap();
		vars = new VarMap();
		edits = new EditMap();
		infeasibleRows.splice(0, infeasibleRows.length);
		objective = new Row();
		artificial = new Row();
		idTick = 1;
	}
	
	public function addConstraint(constraint:Constraint):Void {
		if (constraints.exists(constraint)) {
			throw Error.DuplicateConstraint;
		}
		
		var tag = new Tag();
		var row = createRow(constraint, tag);
		var subject = chooseSubject(row, tag);
		
		if (subject.type == SymbolType.INVALID && allDummies(row)) {
			if (!Util.nearZero(row.constant)) {
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
		
		// TODO
		
		// TODO
		// dualOptimize();
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
		var expression = constraint.expression;
		var row = new Row(expression.constant);
		
		for (term in expression.terms) {
			if (!Util.nearZero(term.coefficient)) {
				var symbol:Symbol = getVarSymbol(term.variable);
				var existingRow:Row = rows.get(symbol);
				if (existingRow != null) {
					row.insert(symbol, term.coefficient);
				} else {
					row.insert(existingRow.symbol, term.coefficient);
				}
			}
		}
		
		switch(constraint.operator) {
			case RelationalOperator.LE, RelationalOperator.GE:
				var coefficient:Float = constraint.operator == RelationalOperator.LE ? 1.0 : -1.0;
				var slack = new Symbol(SymbolType.Slack, idTick++);
				tag.marker = slack;
				row.insertSymbol(slack, coefficient);
				if (constraint.strength < Strength.required) {
					var error = new Symbol(SymbolType.Error, idTick++);
					tag.other = error;
					row.insertSymbol(error, -coefficient);
					objective.insertSymbol(error, constraint.strength);
				}
				break;
			case RelationalOperator.EQ:
				if (constraint.strength < Strength.required) {
					var errorPlus = new Symbol(SymbolType.Error, idTick++);
					var errorMinus = new Symbol(SymbolType.Error, idTick++);
					tag.marker = errorPlus;
					tag.other = errorMinus;
					row.insertSymbol(errorPlus, constraint.strength);
					row.insertSymbol(errorMinus, constraint.strength);
				} else {
					var dummy = new Symbol(SymbolType.Dummy, idTick++);
					tag.marker = dummy;
					row.insertSymbol(dummy);
				}
				break;
		}
		
		if (row.constant < 0.0) {
			row.reverseSign();
		}
		
		return row;
	}
	
	private function chooseSubject(row:Row, tag:Tag):Symbol {
		for (key in rows.keys()) {
			if (rows.get(key).type == SymbolType.External) {
				return key;
			}
		}
		
		if (tag.marker.type == SymbolType.Slack || tag.marker.type == SymbolType.Error) {
			if (row.coefficientFor(tag.marker) < 0.0) {
				return tag.marker;
			}
		}
		
		if (tag.other.type == SymbolType.Slack || tag.other.type == Symbol.Error) {
			return tag.other;
		}
		
		return new Symbol();
	}
	
	private function addWithArtificialVariable(row:Row):Bool {
		var artificial = new Symbol(SymbolType.Slack, idTick++);
		// TODO row deep copy
		return false;
	}
	
	private function substitute(symbol:Symbol, row:Row):Void {
		// TODO
	}
	
	private function optimize(objective:Row):Void {
		while (true) {
			var entering:Symbol = getEnteringSymbol(objective);
			if (entering.type == SymbolType.Invalid) {
				return;
			}
			// TODO
		}
	}
	
	private function dualOptimize():Void {
		// TODO
	}
	
	private function getEnteringSymbol(objective:Row):Symbol {
		for (key in objective.cells.keys()) {
			if (key.type != SymbolType.Dummy && objective.cells.get(key) < 0.0) {
				return key;
			}
		}
		
		return new Symbol();
	}
	
	private function getDualEnteringSymbol(row:Row):Symbol {
		// TODO
	}
	
	private function anyPivotableSymbol(row:Row):Symbol {
		for (symbol in row.cells.keys()) {
			if (symbol.type == SymbolType.Slack || symbol.type == SymbolType.Error) {
				return symbol;
			}
		}
		
		return new Symbol();
	}
	
	private function getLeavingRow(entering:Symbol):RowMap {
		var ratio:Float = 200000000;
		// TODO need to return an iterator
	}
	
	private function getMarkerLeavingRow(marker:Symbol):RowMap {
		// TODO need to return an iterator
	}
	
	private function removeConstraintEffects(constraint:Constraint, tag:Tag):Void {
		if (tag.marker.type == SymbolType.Error) {
			removeMarkerEffects(tag.marker, constraint.strength);
		} else if (tag.other.type == SymbolType.Error) {
			removeMarkerEffects(tag.other, constraint.strength);
		}
	}
	
	private function removeMarkerEffects(marker:Symbol, strength:Float):Void {
		var row:Row = rows.get(marker);
		if (row != null) {
			objective.insertRow(row, -strength);
		} else {
			objective.insertSymbol(marker, -strength);
		}
	}
	
	private function allDummies(row:Row):Bool {
		for (cell in row.cells) {
			if (cell.type != SymbolType.Dummy) {
				return false;
			}
		}
		return true;
	}
}

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