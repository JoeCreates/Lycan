package lycan.ui.layouts;

import lycan.ui.events.UIEvent;
import lycan.ui.widgets.Widget;

using lycan.util.structure.container.BitSet;

// Describes alignment. Note that conflicting combinations of flags have undefined meanings.
class Alignment {
	public static inline var NONE:Int = 0x00000000;
	public static inline var LEFT:Int = 0x00000001;
	public static inline var RIGHT:Int = 0x00000002;
	public static inline var HORIZONTAL_CENTER:Int = 0x00000004;
	public static inline var TOP:Int = 0x00000020;
	public static inline var BOTTOM:Int = 0x00000040;
	public static inline var VERTICAL_CENTER:Int = 0x00000080;

	public static inline var CENTER:Int = HORIZONTAL_CENTER | VERTICAL_CENTER;
}

// TODO generalize this to actual point, or % along the edge of a layout etc
enum AnchorPoint {
	NONE;
	LEFT;
	RIGHT;
	HORIZONTAL_CENTER;
	TOP;
	BOTTOM;
	VERTICAL_CENTER;
}

// Base class of geometry managers
@:access(lycan.ui.UIObject)
class Layout {
	private var align(default, null):Int;
	// private var anchorPoint(default, set):AnchorPoint; // TODO

	public var owner(default, set):Widget;
	//public var dirty(default, set):Bool; // TODO

	public function new() {
		align = Alignment.NONE;
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