package lycan.ui.layouts;

import lycan.ui.events.UIEvent;
import lycan.ui.widgets.Widget;

// Base class of geometry managers
@:access(lycan.ui.UIObject)
class Layout {
	public var owner(default, set):Widget;
	//public var dirty(default, set):Bool; // TODO
	//public var enabled:Bool; // TODO
	
	public function new() {
		//dirty = false;
		//enabled = true;
	}
	
	public function event(e:UIEvent):Bool {
		return false;
	}
	
	public function count() {
		return owner.children.length;
	}
	
	public function isEmpty() {
		return owner.children.isEmpty();
	}
	
	public function update() {
		Sure.sure(owner != null);
	}
	
	public function set_owner(owner:Widget):Widget {
		Sure.sure(owner != null);
		Sure.sure(this.owner == null); // TODO Don't support changing owners yet
		this.owner = owner;
		
		// TODO dispatch owner change/relayout event
		
		return this.owner;
	}
}