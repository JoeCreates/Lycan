package lycan.ui;

import lycan.ui.events.UIEvent;

enum FindChildOptions {
	FindDirectChildrenOnly;
}

class UIObject {
	private static var idTick:Int = 0;

	public var parent(default, set):UIObject;
	public var name(get, null):String;
	public var id(default, null):Int;
	public var receiveChildEvents:Bool;
	public var sendChildEvents:Bool;
	public var enabled(default, set):Bool;

	public var children(default, null):List<UIObject>;
	private var eventFilters:List<UIObject>;

	public var isWidgetType(get, never):Bool;

	public function new(?parent:UIObject = null, ?name:String = null) {
		this.name = name;
		id = idTick++;
		receiveChildEvents = false;
		sendChildEvents = true;
		enabled = true;

		children = new List<UIObject>();
		eventFilters = new List<UIObject>();

		this.parent = parent;
	}

	public function installEventFilter(filter:UIObject):Void {
		Sure.sure(filter != null);

		eventFilters.add(filter); // TODO make event filters event-specific, don't just filter everything
	}

	public function removeEventFilter(filter:UIObject):Void {
		Sure.sure(filter != null);
		Sure.sure(eventFilters != null);

		eventFilters.remove(filter);
	}

	public function filter(e:UIEvent):Bool {
		for (filter in eventFilters) {
			if (filter.event(e)) {
				return true;
			}
		}
		return false;
	}

	public function event(e:UIEvent):Bool {
		Sure.sure(e != null);

		if (filter(e)) { // Does an event filter want to consume the event
			return true;
		}

		if (sendChildEvents && childEvent(e)) { // Does a parent want to consume the event (recursive)
			return true;
		}

		return switch(e.type) {
			case EventType.ChildAdded:
				childAddedEvent(cast e);
			case EventType.ChildRemoved:
				childRemovedEvent(cast e);
			default:
				// if(type >= MAX_USER) { // TODO custom events added to e above a max range
				// customEvent(e);
				// }
				// break;
				false;
		}
	}

	private function childEvent(e:UIEvent):Bool {
		Sure.sure(e != null);

		if (parent != null && parent.receiveChildEvents) {
			return parent.event(e);
		}

		return false;
	}

	// This can be reimplemented to handle a child being added to the object
	private function childAddedEvent(e:ChildEvent) {
		Sure.sure(e != null);
		return true;
	}

	private function childRemovedEvent(e:ChildEvent) {
		Sure.sure(e != null);
		return true;
	}

	public function addChild(child:UIObject) {
		Sure.sure(child != null);
		child.parent = this;
		childAddedEvent(new ChildEvent(EventType.ChildAdded, child));
	}

	public function removeChild(child:UIObject) {
		Sure.sure(child != null);

		var removed = children.remove(child);
		Sure.sure(removed == true);
		child.parent = null;
		childRemovedEvent(new ChildEvent(EventType.ChildRemoved, child));
	}

	public function findChildren(name:String, ?findOption:FindChildOptions):List<UIObject> {
		Sure.sure(name != null);

		if(findOption == null) {
			findOption = FindDirectChildrenOnly;
		}

		return switch(findOption) {
			case FindDirectChildrenOnly:
				return findChildrenHelper(name, new List<UIObject>());
		}
	}

	private function findChildrenHelper(name:String, list:List<UIObject>):List<UIObject> {
		Sure.sure(name != null);

		for (child in children) {
			if (name == child.name) {
				list.push(child);
			}
		}
		return list;
	}

	private function get_name():String {
		if (name == null) {
			return Std.string(id);
		}

		return name;
	}

	private function get_isWidgetType():Bool {
		return false;
	}

	private function set_parent(parent:UIObject):UIObject {
		if (this.parent != null) {
			this.parent.children.remove(this);
			this.parent.event(new ChildEvent(EventType.ChildRemoved, this));
		}

		if(parent != null) {
			parent.children.add(this);
			parent.event(new ChildEvent(EventType.ChildAdded, this));
		}

		return this.parent = parent;
	}

	private function set_enabled(enabled:Bool):Bool {
		return this.enabled = enabled;
	}
}