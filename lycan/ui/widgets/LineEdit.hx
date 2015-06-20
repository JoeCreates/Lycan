package lycan.ui.widgets;

import lycan.ui.events.UIEvent.DragEnterEvent;
import lycan.ui.events.UIEvent.DragLeaveEvent;
import lycan.ui.events.UIEvent.DragMoveEvent;
import lycan.ui.events.UIEvent.KeyEvent;
import lycan.ui.widgets.Widget.KeyboardFocusPolicy;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import lycan.ui.renderer.ITextRenderItem;
import lycan.ui.events.UIEvent.EventType;
import openfl.ui.Keyboard;

class LineEdit extends Widget {
	public var textGraphic(default, set):ITextRenderItem;
	private var restrictInput:EReg = ~/^[A-Za-z0-9]+$/; // Limit *event input* to English alphanumerics
	public var maxLength:Int = 255;
	public var signal_textEdited = new Signal1<String>();
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
		keyboardFocusPolicy = KeyboardFocusPolicy.StrongFocus;
	}
	
	public function backspace() {
		var text = textGraphic.get_text();
		var len = text.length;
		
		if (len > 0) {
			textGraphic.set_text(text.substring(0, len - 1));
		}
	}
	
	override public function keyPressEvent(e:KeyEvent) {
		if (e.charCode == Keyboard.BACKSPACE || e.charCode == Keyboard.DELETE) {
			backspace();
			return;
		}
		
		if (textGraphic.get_text().length >= maxLength) {
			return;
		}
		
		if (e.type == EventType.KeyPress) {
			var evtText = e.text();
			
			if (evtText != null && evtText.length == 1) {
				if (restrictInput.match(evtText)) {
					textGraphic.set_text(textGraphic.get_text() + evtText);
					signal_textEdited.dispatch(textGraphic.get_text());
				}
			}
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