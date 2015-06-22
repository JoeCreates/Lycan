package lycan.ui.widgets;
import lycan.ui.UIObject;

import lycan.ui.layouts.Layout;

class LayoutContainer extends Widget {
	public function new(layout:Layout, ?parent:UIObject = null, ?name:String) {
		super(parent, name);
		this.layout = layout;
	}
	
	override public function addChild(child:UIObject) {
		updateGeometry();
		super.addChild(child);
	}
	
	override public function updateGeometry() {
		super.updateGeometry();
	}
}