package lycan.constraint.frontend;

import lycan.constraint.Expression;
import lycan.constraint.Variable;

class Resolver implements IResolver {
	private var variables:Map<String, Variable>;
	
	public function new() {
		variables = new Map<String, Variable>();
	}
	
	public function resolveVariable(name:String):Variable {
		Sure.sure(name != null);
		
		var v = variables.get(name);
		if (v != null) {
			return v;
		} else {
			v = new Variable(name);
			variables.set(name, v);
			return v;
		}
		
		return v;
	}
	
	public function resolveConstant(expression:String):Expression {
		Sure.sure(expression != null);
		
		var constant:Float = Std.parseFloat(expression);
		
		if (Math.isNaN(constant)) {
			throw "Failed to parse constant expression: " + expression;
			return null;
		}
		
		return new Expression(constant);
	}
	
	public function traceVariables():Void {
		for (variable in variables) {
			trace(variable.name + ": " + variable.value);
		}
	}
}