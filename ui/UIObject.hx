package lycan.ui ;

import lycan.ui.events.UIEvent;

enum FindChildOptions {
	FindDirectChildrenOnly;
	FindChildrenRecursively;
}

class UIObject {
	public var dirty:Bool = false;
	public var parent:UIObject = null;
	public var children:List<UIObject>;
	public var name:String = null;
	public var uid:Int;
	public var sendChildEvents:Bool;
	public var receiveChildEvents:Bool;
	public var isWidgetType(get, never):Bool;
	
	public function new(?parent:UIObject, ?name:String) {
		this.parent = parent;
		children = new List<UIObject>();
		this.name = name;
		uid = cast (Math.random() * 1073741824);
		sendChildEvents = true;
		receiveChildEvents = true;
	}
	
	public function event(e:UIEvent):Bool {
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
	
	private function childEvent(e:ChildEvent) {
		
	}
	
	private function customEvent(e:UIEvent) {
		
	}
	
	//public function installEventFilter
	//public function removeEventFilter
	//public function eventFilter(widget:IWidget, e:UIEvent):Bool {
	//	return false;
	//}
	
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
}