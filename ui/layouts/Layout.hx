package lycan.ui.layouts;
import lycan.ui.events.UIEvent;
import lycan.ui.UIObject;
import lycan.ui.widgets.Widget;

class Layout extends UIObject {	
	public function new(?parent:UIObject = null, ?name:String) {
		super(parent, name);
		
		#if debug
		if(name == null) {
			this.name = Type.getClassName(Type.getClass(this));
		}
		#end
	}
	
	override public function event(e:UIEvent):Bool {
		var handled = super.event(e);
		
		if(!handled) {
			parent.event(e);
		}
		
		return handled;
	}
	
	public function count() {
		return children.length;
	}
	
	public function isEmpty() {
		return children.isEmpty();
	}
}