package lycan.constraint;

import lycan.constraint.Constraint.RelationalOperator;
import lycan.constraint.Solver.SolverError;
import lycan.constraint.Symbol.SymbolType;
import openfl.Vector;

class Solver {
	// TODO ObjectMap use object references as keys, which might be a problem?
	// TODO Haxe maps don't have key,value pair iteration, which makes this implementation less 1:1 and way more inefficient currently
	private var constraints:ConstraintMap;
	private var rows:RowMap;
	private var vars:VarMap;
	private var edits:EditMap;
	private var infeasibleRows:Vector<Symbol>;
	private var objective:Row;
	private var artificial:Row;
	private var idTick:Int;
	
	public function new() {
		reset();
	}
	
	public function reset():Void {
		rows = new RowMap();
		constraints = new ConstraintMap();
		vars = new VarMap();
		edits = new EditMap();
		infeasibleRows = new Vector<Symbol>();
		objective = new Row();
		artificial = null;
		idTick = 1;
	}
	
	public function addConstraint(constraint:Constraint):Void {
		if (constraints.exists(constraint)) {
			throw SolverError.DuplicateConstraint;
		}
		
		var tag:Tag = new Tag();
		var row:Row = createRow(constraint, tag);
		var subject:Symbol = chooseSubject(row, tag);
		
		if (subject.type == SymbolType.Invalid && allDummies(row)) {
			if (!Util.nearZero(row.constant)) {
				throw SolverError.UnsatisfiableConstraint;
			} else {
				subject = tag.marker;
			}
		}
		
		if (subject.type == SymbolType.Invalid) {
			if (!addWithArtificialVariable(row)) {
				throw SolverError.UnsatisfiableConstraint;
			}
		} else {
			row.solveForSymbol(subject);
			substitute(subject, row);
			rows.set(subject, row);
		}
		
		constraints.set(constraint, tag);
		
		optimize(objective);
	}
	
	public function removeConstraint(constraint:Constraint):Void {
		var tag:Tag = constraints.get(constraint);
		
		if (tag == null) {
			throw SolverError.UnknownConstraint;
		}
		
		constraints.remove(constraint);
		
		removeConstraintEffects(constraint, tag);
		
		var row:Row = rows.get(tag.marker);
		
		if (row != null) {
			rows.remove(tag.marker);
		} else {
			row = getMarkerLeavingRow(tag.marker);
			
			if (row == null) {
				throw SolverError.InternalSolverError;
			}
			
			var leaving:Symbol = tag.marker;
			rows.remove(tag.marker);
			row.solveForSymbols(leaving, tag.marker);
			substitute(tag.marker, row);
		}
		
		optimize(objective);
	}
	
	public function hasConstraint(constraint:Constraint):Bool {
		return constraints.exists(constraint);
	}
	
	public function addEditVariable(variable:Variable, strength:Float):Void {
		if (edits.exists(variable)) {
			throw SolverError.DuplicateEditVariable;
		}
		
		strength = Strength.clip(strength);
		
		if (strength == Strength.required) {
			throw SolverError.BadRequiredStrength;
		}
		
		var terms = new Vector<Term>();
		terms.push(new Term(variable)); // TODO check the original code, why did it work there?
		var constraint = new Constraint(new Expression(terms), RelationalOperator.EQ, strength);
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
			throw SolverError.UnknownEditVariable;
		}
		
		removeConstraint(edit.constraint);
		edits.remove(variable);
	}
	
	public function hasEditVariable(variable:Variable):Bool {
		return edits.exists(variable);
	}
	
	public function suggestValue(variable:Variable, value:Float):Void {
		var info = edits.get(variable);
		if (info == null) {
			throw SolverError.UnknownEditVariable;
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
			return;
		}
		
		for (key in rows.keys()) {
			var current_row:Row = rows.get(key);
			var coefficient:Float = current_row.coefficientFor(info.tag.marker);
			if (coefficient != 0.0 && current_row.add(delta * coefficient) < 0.0 && key.type != SymbolType.External) {
				infeasibleRows.push(key);
			}
		}
		
		dualOptimize();
	}
	
	public function updateVariables():Void {
		for (key in vars.keys()) {
			var row:Row = rows.get(vars.get(key));
			
			if (row == null) {
				key.value = 0.0;
			} else {
				key.value = row.constant;
			}
		}
	}
	
	private function getVarSymbol(variable:Variable):Symbol {
		var symbol:Symbol = null;
		if (vars.exists(variable)) {
			symbol = vars.get(variable);
		} else {
			symbol = new Symbol(SymbolType.Slack, idTick++);
			vars.set(variable, symbol);
		}
		return symbol;
	}
	
	private function createRow(constraint:Constraint, tag:Tag):Row {
		var expression:Expression = constraint.expression;
		var row:Row = new Row(expression.constant);
		
		for (term in expression.terms) {
			if (!Util.nearZero(term.coefficient)) {
				var symbol:Symbol = getVarSymbol(term.variable);
				var otherRow:Row = rows.get(symbol);
				if (otherRow == null) {
					row.insertSymbol(symbol, term.coefficient);
				} else {
					row.insertRow(otherRow, term.coefficient);
				}
			}
		}
		
		switch(constraint.operator) {
			case RelationalOperator.LE, RelationalOperator.GE: {
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
			}
			case RelationalOperator.EQ: {
				if (constraint.strength < Strength.required) {
					var errorPlus = new Symbol(SymbolType.Error, idTick++);
					var errorMinus = new Symbol(SymbolType.Error, idTick++);
					tag.marker = errorPlus;
					tag.other = errorMinus;
					row.insertSymbol(errorPlus, constraint.strength);
					row.insertSymbol(errorMinus, constraint.strength);
					objective.insertSymbol(errorPlus, constraint.strength);
					objective.insertSymbol(errorMinus, constraint.strength);
				} else {
					var dummy = new Symbol(SymbolType.Dummy, idTick++);
					tag.marker = dummy;
					row.insertSymbol(dummy);
				}
			}
		}
		
		if (row.constant < 0.0) {
			row.reverseSign();
		}
		
		return row;
	}
	
	private function chooseSubject(row:Row, tag:Tag):Symbol {
		for (key in row.cells.keys()) {
			if (key.type == SymbolType.External) {
				return key;
			}
		}
		
		if (tag.marker.type == SymbolType.Slack || tag.marker.type == SymbolType.Error) {
			if (row.coefficientFor(tag.marker) < 0.0) {
				return tag.marker;
			}
		}
		
		if (tag.other != null && (tag.other.type == SymbolType.Slack || tag.other.type == SymbolType.Error)) {
			if (row.coefficientFor(tag.other) < 0.0) {
				return tag.other;
			}
		}
		
		return new Symbol();
	}
	
	private function addWithArtificialVariable(row:Row):Bool {
		var art = new Symbol(SymbolType.Slack, idTick++);
		rows.set(art, row.deepCopy());
		this.artificial = row.deepCopy();
		
		optimize(this.artificial);
		var success:Bool = Util.nearZero(this.artificial.constant);
		this.artificial = row.deepCopy(); // TODO probably wrong here
		
		var row:Row = null;
		for (key in rows.keys()) {
			if (key == art) {
				row = rows.get(key);
				break;
			}
		}
		
		if (row != null) {
			for (key in rows.keys()) {
				if (rows.get(key) == row) {
					rows.remove(key);
				}
				if (Lambda.count(row.cells) == 0) {
					return success;
				}
				var entering:Symbol = anyPivotableSymbol(row);
				if (entering.type == SymbolType.Invalid) {
					return false;
				}
				row.solveForSymbols(art, entering);
				substitute(entering, row);
				rows.set(entering, row);
			}
		}
		
		for (row in rows) {
			row.remove(art);
		}
		objective.remove(art);
		return success;
	}
	
	private function substitute(symbol:Symbol, row:Row):Void {
		for (key in rows.keys()) {
			var current_row:Row = rows.get(key);
			current_row.substitute(symbol, row);
			if (key.type != SymbolType.External && current_row.constant < 0.0) {
				infeasibleRows.push(key);
			}
		}
		
		objective.substitute(symbol, row);
		if (artificial != null) {
			artificial.substitute(symbol, row);
		}
	}
	
	private function optimize(objective:Row):Void {
		while (true) {
			var entering:Symbol = getEnteringSymbol(objective);
			if (entering.type == SymbolType.Invalid) {
				return;
			}
			var leavingRow:Row = getLeavingRow(entering);
			if (leavingRow == null) {
				throw SolverError.InternalSolverError;
			}
			var leaving:Symbol = null;
			for (key in rows.keys()) {
				if (rows.get(key) == leavingRow) {
					leaving= key;
				}
			}
			rows.remove(leaving);
			leavingRow.solveForSymbols(leaving, entering);
			substitute(entering, leavingRow);
			rows.set(entering, leavingRow);
		}
	}
	
	private function dualOptimize():Void {
		while (infeasibleRows.length > 0) {
			var leaving:Symbol = infeasibleRows.pop();
			var row:Row = rows.get(leaving);
			if (row != null && row.constant < 0.0) {
				var entering:Symbol = getDualEnteringSymbol(row);
				if (entering.type == SymbolType.Invalid) {
					throw SolverError.InternalSolverError;
				}
				rows.remove(entering);
				row.solveForSymbols(leaving, entering);
				substitute(entering, row);
				rows.set(entering, row);
			}
		}
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
		var entering = new Symbol();
		var ratio:Float = 200000000.0; // TODO float max
		for (key in row.cells.keys()) {
			if (key.type != SymbolType.Dummy) {
				var current_cell:Float = row.cells.get(key);
				if (current_cell > 0.0) {
					var coefficient:Float = objective.coefficientFor(key);
					var r:Float = coefficient / current_cell;
					if (r < ratio) {
						ratio = r;
						entering = key;
					}
				}
			}
		}
		return entering;
	}
	
	private function anyPivotableSymbol(row:Row):Symbol {
		for (symbol in row.cells.keys()) {
			if (symbol.type == SymbolType.Slack || symbol.type == SymbolType.Error) {
				return symbol;
			}
		}
		
		return new Symbol();
	}
	
	private function getLeavingRow(entering:Symbol):Row {
		var ratio:Float = 200000000;
		
		var row:Row = null;
		for (key in rows.keys()) {
			if (key.type != SymbolType.External) {
				var candidateRow:Row = rows.get(key);
				var temp = candidateRow.coefficientFor(entering);
				if (temp < 0.0) {
					var temp_ratio = ( -candidateRow.constant / temp);
					if (temp_ratio < ratio) {
						ratio = temp_ratio;
						row = candidateRow;
					}
				}
			}
		}
		
		return row;
	}
	
	private function getMarkerLeavingRow(marker:Symbol):Row {
		var fmax:Float = 200000000; // TODO need float max
		var r1:Float = fmax;
		var r2:Float = fmax;
		
		var first:Row = null;
		var second:Row = null;
		var third:Row = null;
		
		for (key in rows.keys()) {
			var candidateRow:Row = rows.get(key);
			var c:Float = candidateRow.coefficientFor(marker);
			if (c == 0.0) {
				continue;
			}
			if (key.type == SymbolType.External) {
				third = candidateRow;
			} else if (c < 0.0) {
				var r:Float = -(candidateRow.constant / c);
				if (r < r1) {
					r1 = r;
					first = candidateRow;
				}
			} else {
				var r:Float = candidateRow.constant / c;
				if (r < r2) {
					r2 = r;
					second = candidateRow;
				}
			}
		}
		if (first != null) {
			return first;
		}
		if (second != null) {
			return second;
		}
		return third;
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
		for (key in row.cells.keys()) {
			if (key.type != SymbolType.Dummy) {
				return false;
			}
		}
		return true;
	}
}

@:enum abstract SolverError(String) {
	var UnsatisfiableConstraint = "The constraint cannot be satisfied.";
	var UnknownConstraint = "The constraint has not been added to the solver.";
	var DuplicateConstraint = "The constraint has already been added to the solver.";
	var UnknownEditVariable = "The edit variable has not been added to the solver.";
	var DuplicateEditVariable = "The edit variable has already been added to the solver.";
	var BadRequiredStrength = "A required strength cannot be used in this context.";
	var InternalSolverError = "An internal solver error occurred.";
}

private class Tag {
	public function new() {
	}
	
	public var marker:Symbol = null;
	public var other:Symbol = null;
}

private class EditInfo {
	public function new() {
	}
	
	public var tag:Tag = null;
	public var constraint:Constraint = null;
	public var constant:Float = 0.0;
}

typedef ConstraintMap = Map<Constraint, Tag>;
typedef RowMap = Map<Symbol, Row>;
typedef VarMap = Map<Variable, Symbol>;
typedef EditMap = Map<Variable, EditInfo>;