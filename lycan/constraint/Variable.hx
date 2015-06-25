package constraint;

class Variable {
	public var name:String(get, set);
	public var value:Float(get, set);
	
	public function new(name:String) {
		this.name = name;
		this.value = 0;
	}
	
	private function get_name():String {
		return name;
	}
	
	private function set_name(name:String):String {
		return this.name = name;
	}
	
	private function get_value:Float {
		return value;
	}
	
	private function set_value(value:Float):Float {
		return this.value = value;
	}
}