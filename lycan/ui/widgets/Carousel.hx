package lycan.ui.widgets;

import lycan.ui.events.UIEvent;
import lycan.ui.UIObject;

class Carousel extends Widget {
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
	
	private function focusNextChild():Bool {
		return false;
	}
	
	private function focusPreviousChild():Bool {
		return false;
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
	
	private function keyboardFocusInEvent(e:KeyboardFocusEvent) {
		#if debug
		trace(name + " gained keyboard focus");
		#end
	}
	
	private function keyboardFocusOutEvent(e:KeyboardFocusEvent) {
		#if debug
		trace(name + " lost keyboard focus");
		#end
	}
	
	private function gamepadFocusInEvent(e:GamepadFocusEvent) {
		#if debug
		trace(name + " gained gamepad focus");
		#end
	}
	
	private function gamepadFocusOutEvent(e:GamepadFocusEvent) {
		#if debug
		trace(name + " lost gamepad focus");
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
	
	private function dragMoveEvent(e:DragMoveEvent) {
		#if debug
		trace(name + " got drag move");
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
	
	private function propertyChangeEvent(e:PropertyChangeEvent) {
		#if debug
		trace(name + " had a property change");
		#end
	}
	
	private function layoutRequestEvent(e:UIEvent) {
		#if debug
		trace(name + " got a layout request");
		#end
		
		//if (e.type == Type.LayoutRequest) {
			// The top level object (or its layout if it has one) recalculates geometry for all dirty children
			// The layout recursively proceeds down the object tree to determine the constraints for each item until it reaches the dirty layout.
			// It produces a final size constraint for the whole layout, which may change the size of the parent widget
			
			// TODO
		//}
	}
				
	private function gamepadAxisMoveEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad axis event");
		#end
	}
	
	private function gamepadButtonDownEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad button down event");
		#end
	}
	
	private function gamepadButtonUpEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad button up event");
		#end
	}
	
	private function gamepadConnectEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad connect event");
		#end
	}
	
	private function gamepadDisconnectEvent(e:GamepadEvent) {
		#if debug
		trace(name + " got a gamepad disconnect event");
		#end
	}
}

