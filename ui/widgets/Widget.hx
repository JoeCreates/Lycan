package lycan.ui.widgets;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import lycan.ui.events.UIEvent;
import lycan.ui.layouts.Layout;
import lycan.ui.layouts.SizePolicy;
import lycan.ui.UIObject;
import Sure;

enum Direction {
	LEFT;
	UP;
	RIGHT;
	DOWN;
}

// TODO does use of floats rather than ints matter?
class Widget extends UIObject {
	public var layout:Layout = null;
	public var enabled:Bool = true;
	public var modal:Bool = false;
	public var x:Int = 0;
	public var y:Int = 0;
	public var width:Int = 0;
	public var height:Int = 0;
	public var sizePolicy:SizePolicy;
	public var minWidth:Int = 0;
	public var minHeight:Int = 0;
	public var maxWidth:Int = 10000;
	public var maxHeight:Int = 10000;
	public var sizeIncrement:FlxPoint = FlxPoint.get(1, 1);
	public var focus:Bool = false;
	public var shown:Bool = true;
	public var acceptDrops:Bool = true;
	public var paddingLeft:Int = 0;
	public var paddingTop:Int = 0;
	public var paddingRight:Int = 0;
	public var paddingBottom:Int = 0;
	public var marginLeft:Int = 0;
	public var marginTop:Int = 0;
	public var marginRight:Int = 0;
	public var marginBottom:Int = 0;
	
	public var hoverable:Bool = true;
	public var selectable:Bool = true;
	// TODO multitouch?
	
	public function new(?parent:UIObject = null, ?name:String) {
		super(parent, name);
	}
	
	/*
	public function getNearestChildForDirection(direction:Direction, wrapAround:Bool = true):Widget {
		
	}
	*/
	
	public function innerRect():FlxRect {
		return FlxRect.get(x, y, width, height); // TODO
	}
	
	public function borderRect():FlxRect {
		return FlxRect.get(x, y, width, height);
	}
	
	public function outerRect():FlxRect {
		return FlxRect.get(x, y, width, height); // TODO
	}
	
	public function updateGeometry() {
		// Invalidates the current layout
		if(layout != null) {
			layout.dirty = true;
		}
		
		// Mark this and all parent objects as dirty
		var p = cast(this, UIObject);
		while (true) {
			p.dirty = true;
			
			if (p.parent != null) {
				p = p.parent;
			} else {
				break;
			}
		}
		
		// Ask the top-level object to recalculate the geometries of the dirty objects
		p.event(new UIEvent(Type.LayoutRequest));
	}
	
	public function draw() {
	
	}
	
	public function close() {
		
	}
	
	override public function event(e:UIEvent):Bool {
		switch(e.type) {
			case Type.PointerPress:
				pointerPressEvent(cast e);
			case Type.PointerMove:
				pointerMoveEvent(cast e);
			case Type.PointerRelease:
				pointerReleaseEvent(cast e);
			default:
				return super.event(e);
		}
		
		return true;
		
		//if (e.type == Type.LayoutRequest) {
			// The top level object (or its layout if it has one) recalculates geometry for all dirty children
			// The layout recursively proceeds down the object tree to determine the constraints for each item until it reaches the dirty layout.
			// It produces a final size constraint for the whole layout, which may change the size of the parent widget
			
			// TODO
		//}
	}
	
	override private function get_isWidgetType():Bool {
		return true;
	}
	
	private function pointerPressEvent(e:PointerEvent) {
		trace("Received pointer press");
	}
	
	private function pointerReleaseEvent(e:PointerEvent) {
		trace("Received pointer release");
	}
	
	private function pointerMoveEvent(e:PointerEvent) {
		trace("Received pointer move");
	}
	
	/*
	private function wheelEvent(e:WheelEvent) {
		
	}
	
	private function keyPressEvent(e:KeyboardEvent) {
		
	}
	
	private function keyReleaseEvent(e:KeyboardEvent) {
		
	}
	
	private function focusInEvent(e:FocusEvent) {
		
	}
	
	private function focusOutEvent(e:FocusEvent) {
		
	}
	
	private function enterEvent(e:UIEvent) {
		
	}
	
	private function leaveEvent(e:UIEvent) {
		
	}
	
	private function moveEvent(e:MoveEvent) {
		
	}
	
	private function resizeEvent(e:ResizeEvent) {
		
	}
	
	private function closeEvent(e:CloseEvent) {
		
	}
	
	private function dragEnterEvent(e:DragEnterEvent) {
		
	}
	
	private function dragMoveEvent(e:DragMoveEvent) {
		
	}
	
	private function dragLeaveEvent(e:DragLeaveEvent) {
		
	}
	
	private function dropEvent(e:DropEvent) {
		
	}
	
	private function showEvent(e:ShowEvent) {
		
	}
	
	private function hideEvent(e:HideEvent) {
		
	}
	
	private function changeEvent(e:ChangeEvent) {
		
	}
	*/
	
	// Returns the widget furthest down the tree with the mouse inside it, or null if the mouse is inside none of them.
	public static function findHoveredWidget(w:Widget, point:FlxPoint):Widget {
		Sure.sure(w != null);
		Sure.sure(point != null);
		
		while (true) {
			var child = findHoveredChild(w, point);
			
			if (child == null) {
				break;
			}
			
			w = child;
		}
		
		return w;
	}
	
	// Returns the first hovered child, if the widget has one
	private static function findHoveredChild(w:Widget, point:FlxPoint):Widget {
		Sure.sure(w != null);
		Sure.sure(point != null);
		
		if (w.children == null) {
			return null;
		}
		
		for (child in w.children) {
			if (child.isWidgetType) {
				var childWidget:Widget = cast child;
				
				if (isPointOver(w, point)) {
					return childWidget;
				}
			}
		}
		
		return null;
	}
	
	private static function isPointOver(w:Widget, point:FlxPoint):Bool {
		return w.borderRect().containsFlxPoint(point);
	}
}