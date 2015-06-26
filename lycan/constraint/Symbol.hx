package lycan.constraint;

enum SymbolType {
	Invalid;
	External;
	Slack;
	Error;
	Dummy;
}

class Symbol {
	public var type(get, null):SymbolType;
	public var id(get, null):Int;
	
	public function new(?type:SymbolType, id:Int = 0) {
		if (type == null) {
			type = SymbolType.Invalid;
		}
		this.type = type;
		this.id = id;
	}
	
	private function get_type():SymbolType {
		return type;
	}
	
	private function get_id():Int {
		return id;
	}
}