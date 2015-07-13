package lycan.ai;

import haxe.ds.GenericStack;
import world.entities.BaseEntity;

// A node in our behaviour-tree-with-stacks/CES hybrid AI solution
class Node {
	public var id(default, null):Int;
	private static var idCounter:Int = 0;
	
	private var entity:BaseEntity;
	
	private var history = new GenericStack<Node>();
	private var future = new GenericStack<Node>();
	
	private var children = new List<Node>();
	private var parent:Node;
	
	public inline function new(?parent:Node) {
		if (parent != null) {
			this.parent = parent;
		}
		
		id = idCounter;
		idCounter++;
	}
	
	// Must evaluate to true prior to entering the node
	private function precondition():Bool {
		throw "Implement me";
	}
	
	// Must evaluate to true after exiting the node
	private function postcondition():Bool {
		throw "Implement me";
	}
	
	// Must evaluate to true immediately before the node updates
	private function updateInvariant():Bool {
		throw "Implement me";
	}
}