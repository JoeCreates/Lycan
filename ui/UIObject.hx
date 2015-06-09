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
	
	public function new(?parent:UIObject, ?name:String) {
		this.parent = parent;
		children = new List<UIObject>();
		this.name = name;
		uid = cast (Math.random() * 1073741824);
		sendChildEvents = true;
		receiveChildEvents = true;
	}
	
	public function event(e:UIEvent):Bool {
		if (e.type == Type.LayoutRequest) {
			// The top level object (or its layout if it has one) recalculates geometry for all dirty children
			// The layout recursively proceeds down the object tree to determine the constraints for each item until it reaches the dirty layout.
			// It produces a final size constraint for the whole layout, which may change the size of the parent widget
			
			// TODO
		}
		
		return false;
	}
	
	//public function installEventFilter
	//public function removeEventFilter
	//public function eventFilter(widget:IWidget, e:UIEvent):Bool {
	//	return false;
	//}
	
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
	
	private function childEvent(e:ChildEvent) {
		
	}
	
	private function customEvent(e:UIEvent) {
		
	}
	
	private function findChildrenRecursively(name:String, depth:Int = -1):List<UIObject> {
		var list = new List<UIObject>();
		return list;
		
		// TODO		
		if (depth == -1) {
			
		}
	}
}