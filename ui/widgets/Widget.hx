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
		
		#if debug
		if(name == null) {
			this.name = Type.getClassName(Type.getClass(this));
		}
		#end
	}
	
	public function getNearestSelectableForDirection(direction:Direction, wrapAround:Bool = true):Widget {
		// TODO either iterate over the entire widget tree or pass the root object in? e.g. specifying a list widget will cause it to search only in the list items
		// Should be useful for gamepads
		// TODO could delegate this to layouts?
		return null;
	}
	
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
		p.event(new UIEvent(EventType.LayoutRequest));
	}
	
	public function draw() {
	
	}
	
	public function close() {
		
	}
	
	override public function event(e:UIEvent):Bool {
		switch(e.type) {
			case EventType.PointerPress:
				pointerPressEvent(cast e);
			case EventType.PointerMove:
				pointerMoveEvent(cast e);
			case EventType.PointerRelease:
				pointerReleaseEvent(cast e);
			case EventType.WheelScroll:
				wheelEvent(cast e);
			case EventType.KeyPress:
				keyPressEvent(cast e);
				// TODO use tabs to pass focus to children here?
			case EventType.KeyRelease:
				keyReleaseEvent(cast e);
			case EventType.FocusIn:
				focusInEvent(cast e);
			case EventType.FocusOut:
				focusOutEvent(cast e);
			case EventType.HoverEnter:
				hoverEnterEvent(cast e);
			case EventType.HoverLeave:
				hoverLeaveEvent(cast e);
			case EventType.Move:
				moveEvent(cast e);
			case EventType.Resize:
				resizeEvent(cast e);
			case EventType.Close:
				closeEvent(cast e);
			case EventType.DragEnter:
				dragEnterEvent(cast e);
			case EventType.DragLeave:
				dragLeaveEvent(cast e);
			case EventType.Drop:
				dropEvent(cast e);
			case EventType.Show:
				showEvent(cast e);
			case EventType.Hide:
				hideEvent(cast e);
			case EventType.LocaleChange:
				localeChangeEvent(cast e);
			case EventType.PropertyChange:
				propertyChange(cast e);
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
		#if debug
		trace(name + " received pointer press");
		#end
	}
	
	private function pointerReleaseEvent(e:PointerEvent) {
		#if debug
		trace(name + " received pointer release");
		#end
	}
	
	private function pointerMoveEvent(e:PointerEvent) {
		#if debug
		trace(name + " received pointer move");
		#end
	}
	
	private function wheelEvent(e:WheelEvent) {
		#if debug
		trace(name + " received mouse wheel scroll");
		#end
	}
	
	private function keyPressEvent(e:KeyEvent) {
		#if debug
		trace(name + " received key press");
		#end
	}
	
	private function keyReleaseEvent(e:KeyEvent) {
		#if debug
		trace(name + " received key release");
		#end
	}
	
	private function focusInEvent(e:FocusEvent) {
		#if debug
		trace(name + " gained focus");
		#end
	}
	
	private function focusOutEvent(e:FocusEvent) {
		#if debug
		trace(name + " lost focus");
		#end
	}
	
	private function hoverEnterEvent(e:HoverEvent) {
		#if debug
		trace(name + " was hovered");
		#end
	}
	
	private function hoverLeaveEvent(e:HoverEvent) {
		#if debug
		trace(name + " was unhovered");
		#end
	}
	
	private function moveEvent(e:MoveEvent) {
		#if debug
		trace(name + " was moved");
		#end
	}
	
	private function resizeEvent(e:ResizeEvent) {
		#if debug
		trace(name + " was resized");
		#end
	}
	
	private function closeEvent(e:CloseEvent) {
		#if debug
		trace(name + " will close");
		#end
	}
		
	private function dragEnterEvent(e:DragEnterEvent) {
		#if debug
		trace(name + " got drag enter");
		#end	
	}
	
	private function dragLeaveEvent(e:DragLeaveEvent) {
		#if debug
		trace(name + " drag leave");
		#end
	}
	
	private function dropEvent(e:DropEvent) {
		#if debug
		trace(name + " received drop");
		#end
	}
	
	private function showEvent(e:ShowEvent) {
		#if debug
		trace(name + " was shown");
		#end
	}
	
	private function hideEvent(e:HideEvent) {
		#if debug
		trace(name + " was hidden");
		#end
	}
	
	private function localeChangeEvent(e:LocaleChangeEvent) {
		#if debug
		trace(name + " received a locale change event");
		#end
	}
	
	private function propertyChange(e:PropertyChangeEvent) {
		#if debug
		trace(name + " had a property change");
		#end
	}
	
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