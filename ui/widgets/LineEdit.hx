package lycan.ui.widgets;

import lycan.ui.events.UIEvent.DragEnterEvent;
import lycan.ui.events.UIEvent.DragLeaveEvent;
import lycan.ui.events.UIEvent.DragMoveEvent;
import lycan.ui.events.UIEvent.KeyEvent;
import lycan.ui.widgets.Widget.KeyboardFocusPolicy;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import source.lycan.ui.renderer.ITextRenderItem;
import lycan.ui.events.UIEvent.EventType;

class LineEdit extends Widget {
	public var textGraphic(default, set):ITextRenderItem;
	
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
		keyboardFocusPolicy = KeyboardFocusPolicy.StrongFocus;
	}
	
	public function backspace() {
		
	}
	
	public function delete() {
		
	}
	
	public function cursorForward(mark:Bool, steps:Int) {
		
	}
	
	public function cursorBackward(mark:Bool, steps:Int) {
		
	}
	
	override public function keyPressEvent(e:KeyEvent) {
		if(e.type == EventType.KeyPress) {
			textGraphic.set_text(textGraphic.get_text() + "todo");
		}
	}
	
	private function set_textGraphic(graphic:ITextRenderItem) {		
		width = graphic.get_width();
		height = graphic.get_height();
		return this.textGraphic = graphic;
	}
	
	override private function set_x(x:Int):Int {
		textGraphic.set_x(x);		
		return super.set_x(x);
	}
	
	override private function set_y(y:Int):Int {
		textGraphic.set_y(y);
		return super.set_y(y);
	}
}