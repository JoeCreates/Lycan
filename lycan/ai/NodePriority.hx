package lycan.ai;

// Definition of the priority of a task
class NodePriority {
	public var priority(get, null):Float;
	public var name(get, null):String;
	
	public inline function new(priority:Float, name:String) {
		this.priority = priority;
		this.name = name;
	}
	
	private function get_priority():Float {
		return this.priority;
	}
	
	private function get_name():String {
		return this.name;
	}
}