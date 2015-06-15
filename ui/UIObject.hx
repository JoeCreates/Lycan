package lycan.ui ;

import lycan.ui.events.UIEvent;

enum FindChildOptions {
	FindDirectChildrenOnly;
	FindChildrenRecursively;
}

class UIObject {
	public var dirty:Bool = false;
	private var parent(default,set):UIObject = null;
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
	
	// NOTE this WON'T respect the way that each layout/widget might want to specify the children's iteration order
	// TODO breadth first?
	// TODO should be static method on UIObject instead?
	public function walkChildren(func:UIObject->Void) {
	}
	
	public function findChildren(name:String, ?findOption:FindChildOptions):List<UIObject> {
		if(findOption == null) {
			return findChildrenRecursively(name);
		}
	
		return switch(findOption) {
			case FindDirectChildrenOnly:
				return findChildrenRecursively(name, 1);
			case FindChildrenRecursively:
				return findChildrenRecursively(name);
		}
	}
	
	private function findChildrenRecursively(name:String, depth:Int = -1):List<UIObject> {
		var list = new List<UIObject>();
		return list;
		
		// TODO
		if (depth == -1) {
			
		}
	}
	
	private function get_isWidgetType():Bool {
		return false;
	}
	
	private function set_parent(parent:UIObject):UIObject {
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
		
		if(parent != null) {
			parent.children.add(this);
			// TODO post childAdded events to the current UIApplicationRoot here - have a singleton accessor or instance variable?
		}
		
		return this.parent = parent;
	}
}