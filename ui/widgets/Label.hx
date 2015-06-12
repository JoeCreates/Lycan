package lycan.ui.widgets;

import lycan.ui.renderer.IRenderItem;
import lycan.ui.UIObject;
import source.lycan.ui.renderer.ITextRenderItem;

// A simple text graphic display
class Label extends Widget {
	public var graphic:ITextRenderItem;
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
}