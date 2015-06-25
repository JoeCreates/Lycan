package constraint;

import haxe.Int64;

enum SymbolType {
	Invalid;
	External;
	Slack;
	Error;
	Dummy;
}

class Symbol {
	public var type(get, null):SymbolType;
	public var id(get, null):Int64;
	
	public function new(?type:SymbolType = Invalid, ?id:Int64 = 0) {
		this.type = type;
		this.id = id;
	}
	
	private function get_type():SymbolType {
		return type;
	}
	
	private function get_id():Int64 {
		return id;
	}
}