package lycan.ui.widgets;

import flixel.math.FlxPoint;
import lycan.ui.events.UIEvent;
import lycan.ui.layouts.Layout;
import lycan.ui.layouts.SizePolicy;
import lycan.ui.UIObject;

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
	
	public function new(?parent:UIObject = null, ?name:String) {
		super(parent, name);
	}
	
	/*
	public function getNearestChildForDirection(direction:Direction, wrapAround:Bool = true):Widget {
		
	}
	*/
	
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
	
	/*
	public function draw() {
	
	}
	
	public function close() {
		
	}
	
	private function mousePressEvent(e:MouseEvent) {
		
	}
	
	private function mouseReleaseEvent(e:MouseEvent) {
		
	}
	
	private function mouseDoubleClickEvent(e:MouseEvent) {
		
	}
	
	private function mouseMoveEvent(e:MouseEvent) {
		
	}
	
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
}