package lycan.ui.widgets ;

import flixel.FlxSprite;
import lycan.ui.renderer.IRenderItem;
import lycan.ui.UIObject;

// TODO we might want different sorts of buttons, customizable buttons... so make this a base class and add graphics customizability in subclasses
class Button extends Widget {
	public var unhoveredGraphic(default,set):IRenderItem;
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
	
	private function set_unhoveredGraphic(unhoveredGraphic:IRenderItem) {		
		width = unhoveredGraphic.get_width();
		height = unhoveredGraphic.get_height();
		return this.unhoveredGraphic = unhoveredGraphic;
	}
	
	override private function set_x(x:Int):Int {
		unhoveredGraphic.set_x(x);		
		return super.set_x(x);
	}
	
	override private function set_y(y:Int):Int {
		unhoveredGraphic.set_y(y);
		return super.set_y(y);
	}
}