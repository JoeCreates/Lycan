package lycan.ai;

import haxe.ds.GenericStack;

class Node {
	private var history = new GenericStack<Node>();
	private var children = new List<Node>();
	private var parent:Node;
	
	public inline function new(?parent:Node) {
		if (parent != null) {
			this.parent = parent;
		}
	}
	
	// Must evaluate to true prior to entering the node
	private function precondition():Bool {
		
	}
	
	// Must evaluate to tree after exiting the node
	private function postcondition():Bool {
		
	}
	
	// Must evaluate to true immediately before the node updates
	private function updateInvariant():Bool {
		
	}
	
	private function clone():Void {
		
	}
}