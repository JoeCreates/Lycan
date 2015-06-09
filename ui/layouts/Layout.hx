package lycan.ui.layouts;
import lycan.ui.events.UIEvent;
import lycan.ui.UIObject;
import lycan.ui.widgets.Widget;

class Layout implements ILayoutItem extends UIObject {	
	public function new(?parent:Widget, ?name:String) {
		super(parent, name);
		
		if (parent != null) {
			parent.layout = this;
		}
	}
	
	public function update() {
		
	}
	
	public function addWidget(w:Widget) {
		children.add(w);
	}
	
	public function addLayout(l:Layout) {
		children.add(l);
	}
	
	public function removeWidget(w:Widget) {
		children.remove(w);
	}
	
	public function removeLayout(l:Layout) {
		children.remove(l);
	}
	
	public function count() {
		return children.length;
	}
	
	public function isEmpty() {
		return children.isEmpty();
	}
	
	public function setContentsMargins(left:Int, top:Int, right:Int, bottom:Int) {
		// TODO
	}
	
	private function widgetEvent(e:UIEvent) {
	}
}