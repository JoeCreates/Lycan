package lycan.ui.layouts;
import flixel.math.FlxRect;
import lycan.ui.widgets.Widget;

enum HBoxLayoutDirection {
	LeftToRight;
	RightToLeft;
}

class HBoxLayout extends BoxLayout {
	private var layoutDirection:HBoxLayoutDirection;
	
	// TODO each child widget should get at least its minimum size and at most its maximum size
	// TODO the layout maintains an ordering of the widgets elements and implements the getNext() and getPrevious() functionality for its owner
	// TODO implement size policies for child sizing
	
	public function new(spacing:Int, ?layoutDirection:HBoxLayoutDirection) {
		super(spacing);
		
		if (layoutDirection == null) {
			layoutDirection = LeftToRight;
		}
		
		this.layoutDirection = layoutDirection;
	}
	
	override public function update():Void {
		super.update();
		
		// TODO implement different layout directions and centering + resize policies
		
		var area:FlxRect = owner.innerRect();
		var baseX:Int = Std.int(area.left + spacing);
		var baseY:Int = Std.int(area.top + area.height / 2);
		
		for (child in owner.children) {
			var c:Widget = cast child;
			c.x = baseX;
			c.y = Std.int(baseY - c.height / 2);
			baseX += c.width + spacing;
		}
	}
}