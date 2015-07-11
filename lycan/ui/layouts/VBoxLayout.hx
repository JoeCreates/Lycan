package lycan.ui.layouts;

import lycan.ui.widgets.Widget;

enum VBoxLayoutDirection {
	TopToBottom;
	BottomToTop;
}

class VBoxLayout extends BoxLayout {
	private var layoutDirection:VBoxLayoutDirection;
	
	public function new(spacing:Int, ?layoutDirection:VBoxLayoutDirection) {
		super(spacing);
		
		if (layoutDirection == null) {
			layoutDirection = TopToBottom;
		}
		
		this.layoutDirection = layoutDirection;
	}
	
	override public function update():Void {
		super.update();
		
		for (child in owner.children) {
			
		}
	}
}