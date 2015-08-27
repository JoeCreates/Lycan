package lycan.ui.widgets;

import lycan.ui.layouts.Layout;
import lycan.ui.UIObject;

class LayoutContainer extends Widget {
	public function new(layout:Layout, ?parent:UIObject = null, ?name:String) {
		super(parent, name);
		this.layout = layout;
	}
	
	override public function addChild(child:UIObject) {
		super.addChild(child);
		updateGeometry();
	}
	
	override public function updateGeometry() {
		super.updateGeometry();
		layout.update();
	}
}