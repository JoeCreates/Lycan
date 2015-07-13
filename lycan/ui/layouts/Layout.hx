package lycan.ui.layouts;

import haxe.EnumFlags;
import lycan.ui.events.UIEvent;
import lycan.ui.widgets.Widget;

// TODO may make more sense to have separate horizontal and vertical alignments
enum Alignment {
	Left;
	Right;
	HorizontalCenter;
	Top;
	Bottom;
	VerticalCenter;
}

// TODO generalize this to actual point, or % along the edge of a layout etc
enum AnchorPoint {
	None;
	Left;
	HorizontalCenter;
	Right;
	Top;
	VerticalCenter;
	Bottom;
}

// Base class of geometry managers
@:access(lycan.ui.UIObject)
class Layout {
	private var align(default, null):EnumFlags<Alignment>;
	// private var anchorPoint(default, set):AnchorPoint; // TODO
	
	public var owner(default, set):Widget;
	//public var dirty(default, set):Bool; // TODO
	
	public function new() {
		align = new EnumFlags<Alignment>();
		//anchorPoint = AnchorPoint.None;
		//dirty = false;
	}
	
	public function event(e:UIEvent):Bool {
		switch(e.type) {
			case EventType.ChildAdded:
				childAddedEvent(cast e);
			case EventType.ChildRemoved:
				childRemovedEvent(cast e);
			default:
				return false;
		}
		
		return true;
	}
	
	private function childAddedEvent(e:ChildEvent):Void {
		
	}
	
	private function childRemovedEvent(e:ChildEvent):Void {
		
	}
	
	public function count():Int {
		return owner.children.length;
	}
	
	public function isEmpty():Bool {
		return owner.children.isEmpty();
	}
	
	public function update():Void {
		Sure.sure(owner != null);
	}
	
	/* TODO
	private function set_anchorPoint(anchorPoint:AnchorPoint):AnchorPoint {
		return this.anchorPoint = anchorPoint;
	}
	*/
	
	private function set_owner(owner:Widget):Widget {
		Sure.sure(owner != null);
		Sure.sure(this.owner == null); // TODO Don't support changing owners yet
		this.owner = owner;
		
		// TODO dispatch owner change/relayout event
		
		return this.owner;
	}
}