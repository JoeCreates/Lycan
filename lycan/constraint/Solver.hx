package lycan.constraint;

import lycan.constraint.Constraint.RelationalOperator;
import lycan.constraint.Solver.SolverError;
import lycan.constraint.Symbol.SymbolType;

// TODO pull this in as the haxe-kiwi submodule (potentially try to rename the packages (import-as??) and possibly expose functionality via wrappers?)

class Solver {
	// TODO Haxe maps don't have key,value pair iteration, which makes this implementation less 1:1 and probably way more inefficient - what do?
	private static inline var fMax:Float = 1e20;
	
	private var constraints:ConstraintMap;
	private var rows:RowMap;
	private var vars:VarMap;
	private var edits:EditMap;
	private var infeasibleRows:Array<Symbol>;
	private var objective:Row;
	private var artificial:Row;
	private var idTick:Int;
	
	public function new() {
		reset();
	}
	
	public inline function reset():Void {
		constraints = new ConstraintMap();
		rows = new RowMap();
		vars = new VarMap();
		edits = new EditMap();
		infeasibleRows = new Array<Symbol>();
		objective = new Row();
		artificial = null;
		idTick = 1;
	}
	
	public function addConstraint(constraint:Constraint):Void {
		Sure.sure(constraint != null);
		
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
		Sure.sure(constraint != null);
		
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
	
	public inline function hasConstraint(constraint:Constraint):Bool {
		Sure.sure(constraint != null);
		
		return constraints.exists(constraint);
	}
	
	public function addEditVariable(variable:Variable, strength:Float):Void {
		Sure.sure(variable != null);
		
		if (edits.exists(variable)) {
			throw SolverError.DuplicateEditVariable;
		}
		
		strength = Strength.clip(strength);
		
		if (strength == Strength.required) {
			throw SolverError.BadRequiredStrength;
		}
		
		var terms = new Array<Term>();
		terms.push(new Term(variable));
		var constraint = new Constraint(new Expression(terms), RelationalOperator.EQ, strength);
		addConstraint(constraint);
		var info = new EditInfo(constraint, constraints.get(constraint), 0.0);
		edits.set(variable, info);
	}
	
	public function removeEditVariable(variable:Variable):Void {
		Sure.sure(variable != null);
		
		var edit = edits.get(variable);
		
		if (edit == null) {
			throw SolverError.UnknownEditVariable;
		}
		
		removeConstraint(edit.constraint);
		edits.remove(variable);
	}
	
	public inline function hasEditVariable(variable:Variable):Bool {
		Sure.sure(variable != null);
		
		return edits.exists(variable);
	}
	
	public function suggestValue(variable:Variable, value:Float):Void {
		Sure.sure(variable != null);
		
		var info:EditInfo = edits.get(variable);
		if (info == null) {
			throw SolverError.UnknownEditVariable;
		}
		
		var delta:Float = value - info.constant;
		info.constant = value;
		
		var row:Row = rows.get(info.tag.marker);
		if (row != null) {
			if (row.add(-delta) < 0.0) {
				infeasibleRows.push(info.tag.marker);
			}
			return;
		}
		
		row = rows.get(info.tag.other);
		if (row != null) {
			if (row.add(delta) < 0.0) {
				infeasibleRows.push(info.tag.other);
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
		Sure.sure(variable != null);
		
		var symbol:Symbol = vars.get(variable);
		if (symbol != null) {
			return symbol;
		}
			
		symbol = new Symbol(SymbolType.External, idTick++);
		vars.set(variable, symbol);
		return symbol;
	}
	
	private function createRow(constraint:Constraint, tag:Tag):Row {
		Sure.sure(constraint != null);
		
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
					row.insertSymbol(errorPlus, -1.0);
					row.insertSymbol(errorMinus, 1.0);
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
		Sure.sure(row != null && tag != null);
		
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
		Sure.sure(row != null);
		
		var art:Symbol = new Symbol(SymbolType.Slack, idTick++);
		rows.set(art, row.deepCopy());
		this.artificial = row.deepCopy();
		
		optimize(this.artificial);
		var success:Bool = Util.nearZero(this.artificial.constant);
		this.artificial = null;
		
		var row:Row = rows.get(art);
		if (row != null) {
			for (key in rows.keys()) {
				if (rows.get(key) == row) {
					rows.remove(key);
				}
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
		
		for (row in rows) {
			row.remove(art);
		}
		
		objective.remove(art);
		
		return success;
	}
	
	private function substitute(symbol:Symbol, row:Row):Void {
		Sure.sure(symbol != null && row != null);
		
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
		Sure.sure(objective != null);
		
		while (true) {
			var entering:Symbol = getEnteringSymbol(objective);
			if (entering.type == SymbolType.Invalid) {
				return;
			}
			var entry:Row = getLeavingRow(entering);
			if (entry == null) {
				throw SolverError.InternalSolverError;
			}
			var leaving:Symbol = null;
			for (key in rows.keys()) {
				if (rows.get(key) == entry) {
					leaving = key;
				}
			}
			
			var entryKey:Symbol = null;
			for (key in rows.keys()) {
				if (rows.get(key) == entry) {
					entryKey = key;
				}
			}
			
			rows.remove(entryKey);
			entry.solveForSymbols(leaving, entering);
			substitute(entering, entry);
			rows.set(entering, entry);
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
		Sure.sure(objective != null);
		
		for (key in objective.cells.keys()) {
			if (key.type != SymbolType.Dummy && objective.cells.get(key) < 0.0) {
				return key;
			}
		}
		
		return new Symbol();
	}
	
	private function getDualEnteringSymbol(row:Row):Symbol {
		Sure.sure(row != null);
		
		var entering = new Symbol();
		var ratio:Float = fMax;
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
		Sure.sure(row != null);
		
		for (symbol in row.cells.keys()) {
			if (symbol.type == SymbolType.Slack || symbol.type == SymbolType.Error) {
				return symbol;
			}
		}
		
		return new Symbol();
	}
	
	private function getLeavingRow(entering:Symbol):Row {
		Sure.sure(entering != null);
		
		var ratio:Float = fMax;
		
		var row:Row = null;
		for (key in rows.keys()) {
			if (key.type != SymbolType.External) {
				var candidateRow:Row = rows.get(key);
				var temp = candidateRow.coefficientFor(entering);
				if (temp < 0.0) {
					var temp_ratio = (-candidateRow.constant / temp);
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
		Sure.sure(marker != null);
		
		var fmax:Float = fMax;
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
				var r:Float = -candidateRow.constant / c;
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
		Sure.sure(constraint != null && tag != null);
		
		if (tag.marker.type == SymbolType.Error) {
			removeMarkerEffects(tag.marker, constraint.strength);
		} else if (tag.other.type == SymbolType.Error) {
			removeMarkerEffects(tag.other, constraint.strength);
		}
	}
	
	private function removeMarkerEffects(marker:Symbol, strength:Float):Void {
		Sure.sure(marker != null);
		
		var row:Row = rows.get(marker);
		if (row != null) {
			objective.insertRow(row, -strength);
		} else {
			objective.insertSymbol(marker, -strength);
		}
	}
	
	private function allDummies(row:Row):Bool {
		Sure.sure(row != null);
		
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
	public inline function new() {
		marker = new Symbol();
		other = new Symbol();
	}
	
	public var marker:Symbol;
	public var other:Symbol;
}

private class EditInfo {
	public inline function new(constraint:Constraint, tag:Tag, constant:Float) {
		Sure.sure(constraint != null);
		Sure.sure(tag != null);
		Sure.sure(Math.isFinite(constant));
		
		this.constraint = constraint;
		this.tag = tag;
		this.constant = constant;
	}
	
	public var constraint:Constraint;
	public var tag:Tag;
	public var constant:Float;
}

typedef ConstraintMap = Map<Constraint, Tag>;
typedef RowMap = Map<Symbol, Row>;
typedef VarMap = Map<Variable, Symbol>;
typedef EditMap = Map<Variable, EditInfo>;