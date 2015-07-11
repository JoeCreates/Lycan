package lycan.ai;

// Definition of the priority of a task
class NodePriority {
	public var priority(default, null):Float;
	public var name(default, null):String;
	
	public inline function new(priority:Float, name:String) {
		this.priority = priority;
		this.name = name;
	}
}