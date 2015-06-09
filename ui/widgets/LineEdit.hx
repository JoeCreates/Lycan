package lycan.ui.widgets;

import msignal.Signal.Signal0;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

class LineEdit extends Widget {
	public var text:String = "";
	public var displayText:String = "";
	public var maxLength:Int = 255;
	public var readOnly:Bool = false;
	public var cursorPosition:Int = 0;
	
	public var textChanged = new Signal1<String>();
	public var textEdited = new Signal1<String>();
	public var cursorPositionChanged = new Signal2<Int, Int>();
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
	
	public function backspace() {
		
	}
	
	public function delete() {
		
	}
	
	public function cursorForward(mark:Bool, steps:Int) {
		
	}
	
	public function cursorBackward(mark:Bool, steps:Int) {
		
	}
	
	// TODO override events
	/*
	override public function mousePressEvent(e:MouseEvent) {	
	}
	
	override public function mouseMoveEvent(e:MouseEvent) {
	}
	
	override public function mouseReleaseEvent(e:MouseEvent) {
	}
	
	override public function mouseDoubleClickEvent(e:MouseEvent) {
	}
	
	override public function keyPressEvent(e:KeyEvent) {
	}
	
	override public function focusInEvent(e:FocusEvent) {
	}
	
	override public function focusOutEvent(e:FocusEvent) {
	}
	
	override public function dragMoveEvent(e:DragMoveEvent) {
	}
	
	override public function dragEnterEvent(e:DragEnterEvent) {
	}
	
	override public function dragLeaveEvent(e:DragLeaveEvent) {
	}
	
	override public function dropEvent(e:DropEvent) {
	}
	*/
}