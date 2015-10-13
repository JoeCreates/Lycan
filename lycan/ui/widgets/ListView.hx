package lycan.ui.widgets;

import lycan.ui.renderer.flixel.FlxTextRenderItem;
import lycan.ui.renderer.ITextRenderItem;
import lycan.ui.widgets.buttons.PushButton;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import text.BodyText;

class ListView extends Widget {
	public var signal_currentItemChanged = new Signal2<Widget, Widget>();
	public var signal_itemActivated = new Signal1<Widget>();
	public var signal_itemPressed = new Signal1<Widget>();
	public var signal_itemHovered = new Signal1<Widget>();
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
	
	public function addLabel(graphic:ITextRenderItem, action:Void->Void):Void {
		var label = new Label(this);
		label.graphic = graphic;
	}
}