package lycan.ui.layouts;

import flixel.math.FlxRect;
import lycan.ui.events.UIEvent.ChildEvent;
import lycan.ui.layouts.Layout.Alignment;
import lycan.ui.widgets.Widget;

enum HBoxLayoutDirection {
	LeftToRight;
	RightToLeft;
}

class HBoxLayout extends BoxLayout {
	private var layoutDirection:HBoxLayoutDirection; // The order in which added items are shown in the layout
	
	public function new(spacing:Int, ?layoutDirection:HBoxLayoutDirection, ?alignHorizontal:Alignment, ?alignVertical:Alignment) {
		super(spacing);
		
		if (layoutDirection == null) {
			layoutDirection = LeftToRight;
		}
		
		this.layoutDirection = layoutDirection;
		
		if (alignHorizontal == null) {
			alignHorizontal = HorizontalCenter;
		}
		
		if (alignVertical == null) {
			alignVertical = VerticalCenter;
		}
		
		align.set(alignHorizontal);
		align.set(alignVertical);
	}
	
	override public function update():Void {
		super.update();
		
		// TODO each child widget should get at least its minimum size and at most its maximum size
		// TODO the layout maintains an ordering of the widgets elements and implements the getNext() and getPrevious() functionality for its owner
		
		var area:FlxRect = owner.innerRect();

		if (align.has(Alignment.HorizontalCenter)) {
			layoutHorizonalCentered(area);
		} else {
			layoutOthers(area);
		}
	}
	
	override private function childAddedEvent(e:ChildEvent):Void {
		
	}
	
	override private function childRemovedEvent(e:ChildEvent):Void {
		
	}
	
	private inline function layoutHorizonalCentered(area:FlxRect):Void {
		var childrenWidth:Int = 0;
		for (child in owner.children) {
			var c:Widget = cast child;
			childrenWidth += c.width;
		}
		
		var numChildren:Int = owner.children.length;
		var totalWidth:Int = childrenWidth + (spacing * (numChildren + 2));
		
		var baseX = Std.int(area.left + area.width/2 - totalWidth/2);
		var baseY = getBaseY(area);
		
		for (child in owner.children) {
			var c:Widget = cast child;
			baseX += spacing;
			c.x = baseX;
			baseX += c.width;
			
			if(align.has(Alignment.Bottom)) {
				c.y = Std.int(baseY - c.height);
			} else if (align.has(Alignment.VerticalCenter)) {
				c.y = Std.int(baseY - c.height / 2);
			} else if (align.has(Alignment.Top)) {
				c.y = Std.int(baseY);
			}
		}
	}
	
	private inline function layoutOthers(area:FlxRect):Void {
		var baseX = getBaseX(area);
		var baseY = getBaseY(area);
		
		for (child in owner.children) {			
			var c:Widget = cast child;
			
			if (align.has(Alignment.Left)) {
				c.x = baseX;
				baseX += c.width + spacing;
			} else if (align.has(Alignment.Right)) {
				baseX -= c.width - spacing;
				c.x = baseX;
			}
			
			if(align.has(Alignment.Bottom)) {
				c.y = Std.int(baseY - c.height);
			} else if (align.has(Alignment.VerticalCenter)) {
				c.y = Std.int(baseY - c.height / 2);
			} else if (align.has(Alignment.Top)) {
				c.y = Std.int(baseY);
			}
		}
	}
	
	private inline function getBaseX(area:FlxRect):Int {
		var baseX:Int = 0;
		
		if (align.has(Alignment.Left)) {
			baseX = Std.int(area.left + spacing);
		}
		else if (align.has(Alignment.Right)) {
			baseX = Std.int(area.right - spacing);
		}
		
		return baseX;
	}
	
	private inline function getBaseY(area:FlxRect):Int {
		var baseY:Int = 0;
		
		if (align.has(Alignment.VerticalCenter)) {
			baseY = Std.int(area.top + area.height / 2);
		}
		else if (align.has(Alignment.Bottom)) {
			baseY = Std.int(area.bottom);
		}
		else if (align.has(Alignment.Top)) {
			baseY = Std.int(area.top);
		}
		
		return baseY;
	}
}