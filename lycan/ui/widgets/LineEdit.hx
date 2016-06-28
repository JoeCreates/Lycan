package lycan.ui.widgets;

import lycan.ui.events.UIEvent.EventType;
import lycan.ui.events.UIEvent.KeyEvent;
import lycan.ui.widgets.Widget.KeyboardFocusPolicy;
import msignal.Signal.Signal1;
import openfl.ui.Keyboard;
import flixel.text.FlxText;

class LineEdit extends Widget {
	public var textGraphic(default, set):FlxText;
	private var restrictInput:EReg = ~/^[A-Za-z0-9 ]+$/; // Limit *event input* to English alphanumerics and spaces (TODO make it work with other input)
	public var maxLength:Int = 255;
	public var signal_textEdited = new Signal1<String>();
	public var text(get, set):String;

	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
		keyboardFocusPolicy = KeyboardFocusPolicy.StrongFocus;
	}

	public function backspace() {
		var text = textGraphic.text;
		var len = text.length;

		if (len > 0) {
			textGraphic.text = text.substring(0, len - 1);
			signal_textEdited.dispatch(textGraphic.text);
		}
	}

	override public function keyPressEvent(e:KeyEvent) {
		if (e.charCode == Keyboard.BACKSPACE || e.charCode == Keyboard.DELETE) {
			backspace();
			return true;
		}

		if (textGraphic.text.length >= maxLength) {
			return true;
		}

		if (e.type == EventType.KeyPress) {
			var evtText = e.text();

			if (evtText != null && evtText.length == 1) {
				if (restrictInput.match(evtText)) {
					textGraphic.text += evtText;
					signal_textEdited.dispatch(textGraphic.text);
				}
			}

			return true;
		}

		return false;
	}

	private function set_textGraphic(graphic:FlxText) {
		width = Std.int(graphic.width);
		height = Std.int(graphic.height);
		graphic.x = x;
		graphic.y = y;
		return this.textGraphic = graphic;
	}

	override private function set_x(x:Int):Int {
		if(textGraphic != null) {
			textGraphic.x = x;
		}

		return this.x = x;
	}

	override private function set_y(y:Int):Int {
		if (textGraphic != null) {
			textGraphic.y = y;
		}

		return this.y = y;
	}

	private function get_text():String {
		Sure.sure(textGraphic != null);
		return textGraphic.text;
	}

	private function set_text(text:String):String {
		Sure.sure(textGraphic != null);
		return textGraphic.text = text;
	}
}