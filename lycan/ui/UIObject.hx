package lycan.ui ;

import lycan.ui.events.UIEvent;
import lycan.ui.core.UIApplicationRoot;

enum FindChildOptions {
	FindDirectChildrenOnly;
	FindChildrenRecursively;
}

class UIObject {
	public var dirty:Bool = false;
	public var parent(default,set):UIObject = null;
	private var children:List<UIObject>;
	public var name:String = null;
	public var uid:Int;
	public var sendChildEvents:Bool;
	public var receiveChildEvents:Bool;
	public var isWidgetType(get, never):Bool;
	private var eventFilters:List<UIObject> = new List<UIObject>();
	
	public function new(?parent:UIObject, ?name:String) {
		this.parent = parent;
		children = new List<UIObject>();
		this.name = name;
		uid = cast (Math.random() * 1073741824);
		sendChildEvents = true;
		receiveChildEvents = true;
	}
	
	public function installEventFilter(filter:UIObject):Void {
		Sure.sure(filter != null);		
		
		eventFilters.add(filter);
	}
	
	public function removeEventFilter(filter:UIObject):Void {
		Sure.sure(filter != null);
		Sure.sure(eventFilters != null);
		
		eventFilters.remove(filter);
	}
	
	// Filters events if this object has been installed as an event filter on a watched object
	// Return true if you want to filter the event out i.e. stop it being handled further, else false
	public function eventFilter(object:UIObject, e:UIEvent):Bool {
		Sure.sure(object != null);
		Sure.sure(e != null);
		
		return false;
	}
	
	public function event(e:UIEvent):Bool {
		for (filter in eventFilters) {
			if (filter.event(e)) {
				return true;
			}
		}
		
		switch(e.type) {
			case EventType.ChildAdded, EventType.ChildRemoved:
				childEvent(cast e);
			default:
				// if(type >= MAX_USER) { // TODO custom events added to e above a max range
				// customEvent(e);
				// }
				// break;
				
				return false;
		}
		
		return true;
	}
	
	// Handle user-defined events
	//private function customEvent(e:CustomEvent) {
	//	
	//}
	
	// This can be reimplemented to handle a child being added or removed to the object
	private function childEvent(e:ChildEvent) {
		
	}
	
	public function addChild(child:UIObject) {
		children.add(child);
		child.parent = this;
	}
	
	public function removeChild(child:UIObject) {
		var removed = children.remove(child);
		Sure.sure(removed == true);
		child.parent = null;
	}
	
	public function findChildrenForName(name:String, ?findOption:FindChildOptions):List<UIObject> {
		if(findOption == null) {
			return findChildrenRecursivelyForName(name);
		}
	
		return switch(findOption) {
			case FindDirectChildrenOnly:
				return findChildrenRecursivelyForName(name, 1);
			case FindChildrenRecursively:
				return findChildrenRecursivelyForName(name);
		}
	}
	
	private function findChildrenRecursivelyForName(name:String, depth:Int = -1):List<UIObject> {
		var list = new List<UIObject>();
		return list;
		
		if (depth == -1) {
			
		}
	}
	
	private function get_isWidgetType():Bool {
		return false;
	}
	
	private function set_parent(parent:UIObject):UIObject {
		if (this.parent != null) {
			this.parent.removeChild(this);
			parent.event(new ChildEvent(EventType.ChildRemoved, this));
		}
		
		if(parent != null) {
			parent.children.add(this);
			parent.event(new ChildEvent(EventType.ChildAdded, this));
		}
		
		return this.parent = parent;
	}
}