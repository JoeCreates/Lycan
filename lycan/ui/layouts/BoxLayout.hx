package lycan.ui.layouts;

import lycan.ui.widgets.Widget;

class BoxLayout extends Layout {
	private var spacing:Int;
	
	public function new(spacing:Int) {
		super();
		this.spacing = spacing;
	}
}