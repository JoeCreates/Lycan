package lycan.util;

import haxe.ds.StringMap;

// TODO make more operations possible
class MultiFactorVariable {
	public var object:Dynamic;
	public var field:String;
	/**
	 * Optional function to set value of field. If not specified, reflection is used.
	 */
	public var setter:Float->Void;
	public var factors:StringMap<MultiFactorVariableFactor>;
	
	public function new(setter:Float->Void) {
		//TODO this.object = object;
		//this.field = field;
		this.setter = setter;
		factors = new StringMap<MultiFactorVariableFactor>();
	}
	
	public function updateField() {
		var value:Float = 0;
		var first:Bool = true;
		// TODO we maybe want to keep separate array for optimisation?
		for (f in factors) {
			if (first) {
				first = false;
				value = f.value;
				continue;
			}
			value *= f.value;
		}
		setField(value);
	}
	
	public function setFactor(name:String, value:Float) {
		var factor = factors.get(name);
		
		if (factor == null) {
			factor = new MultiFactorVariableFactor(this);
			factors.set(name, factor);
		}
		
		factor.value = value;
	}
	
	private function setField(value:Float) {
		if (setter != null) {
			setter(value);
		} else if (object != null && field != null) {
			Reflect.setField(object, field, value);
		}
	}
		
}

class MultiFactorVariableFactor {
	public var parent:MultiFactorVariable;
	
	public var value(default, set):Float;
	
	public function new(parent:MultiFactorVariable) {
		this.parent = parent;
	}
	
	private function set_value(val:Float):Float {
		if (val == value) return val;
		this.value = val;
		parent.updateField();
		return val;
	}
}