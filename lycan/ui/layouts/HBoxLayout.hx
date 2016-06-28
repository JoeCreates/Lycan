package lycan.ui.layouts;

import flixel.math.FlxRect;
import lycan.ui.events.UIEvent.ChildEvent;
import lycan.ui.layouts.Layout.Alignment;
import lycan.ui.widgets.Widget;

using lycan.util.structure.container.BitSet;

enum HBoxLayoutDirection {
	LEFT_TO_RIGHT;
	RIGHT_TO_LEFT;
}

class HBoxLayout extends BoxLayout {
	private var direction:HBoxLayoutDirection; // The order in which added items are shown in the layout

	public function new(spacing:Int, ?layoutDirection:HBoxLayoutDirection, alignment:Int = Alignment.CENTER) {
		super(spacing);

		if (layoutDirection == null) {
			layoutDirection = LEFT_TO_RIGHT;
		}
		direction = layoutDirection;
		align |= alignment;
	}

	override public function update():Void {
		super.update();

		// TODO each child widget should get at least its minimum size and at most its maximum size
		// TODO the layout maintains an ordering of the widgets elements and implements the getNext() and getPrevious() functionality for its owner

		var area:FlxRect = owner.borderRect();

		if (align.containsAll(Alignment.HORIZONTAL_CENTER)) {
			layoutHorizonalCentered(area);
		} else {
			layoutOthers(area);
		}
	}

	override private function childAddedEvent(e:ChildEvent):Void {
		update();
	}

	override private function childRemovedEvent(e:ChildEvent):Void {
		update();
	}

	private inline function layoutHorizonalCentered(area:FlxRect):Void {
		var childrenWidth:Float = 0;
		for (child in owner.children) {
			var c:Widget = cast child;
			childrenWidth += c.outerRect().width;
		}

		var numChildren:Int = owner.children.length;

		var totalSpacing:Float = 0;
		if (numChildren == 0) {
			spacing = 0;
		} else if(numChildren % 2 == 0) {
			totalSpacing = spacing * (numChildren + 2);
		} else {
			totalSpacing = spacing * (numChildren + 1);
		}

		var totalWidth:Float = childrenWidth + totalSpacing;
		var baseX = area.left + area.width / 2 - totalWidth / 2;
		var baseY = getBaseY(area);

		for (child in owner.children) {
			var c:Widget = cast child;
			baseX += spacing;
			c.x = Math.round(baseX) + Std.int((c.marginLeft + c.marginRight) / 2); // TODO where does the extra margin addition come from...? Probably a bug...
			baseX += c.outerRect().width;

			if(align.containsAll(Alignment.BOTTOM)) {
				c.y = Std.int(baseY - c.height);
			} else if (align.containsAll(Alignment.VERTICAL_CENTER)) {
				c.y = Std.int(baseY - c.height / 2);
			} else if (align.containsAll(Alignment.TOP)) {
				c.y = Std.int(baseY);
			}
		}
	}

	private inline function layoutOthers(area:FlxRect):Void {
		var baseX = getBaseX(area);
		var baseY = getBaseY(area);

		for (child in owner.children) {
			var c:Widget = cast child;

			if (align.containsAll(Alignment.LEFT)) {
				c.x = baseX;
				baseX += c.width + spacing;
			} else if (align.containsAll(Alignment.RIGHT)) {
				baseX -= c.width - spacing;
				c.x = baseX;
			}

			if(align.containsAll(Alignment.BOTTOM)) {
				c.y = Std.int(baseY - c.height);
			} else if (align.containsAll(Alignment.VERTICAL_CENTER)) {
				c.y = Std.int(baseY - c.height / 2);
			} else if (align.containsAll(Alignment.TOP)) {
				c.y = Std.int(baseY);
			}
		}
	}

	private inline function getBaseX(area:FlxRect):Int {
		var baseX:Int = 0;

		if (align.containsAll(Alignment.LEFT)) {
			baseX = Std.int(area.left + spacing);
		}
		else if (align.containsAll(Alignment.RIGHT)) {
			baseX = Std.int(area.right - spacing);
		}

		return baseX;
	}

	private inline function getBaseY(area:FlxRect):Int {
		var baseY:Int = 0;

		if (align.containsAll(Alignment.VERTICAL_CENTER)) {
			baseY = Std.int(area.top + area.height / 2);
		}
		else if (align.containsAll(Alignment.BOTTOM)) {
			baseY = Std.int(area.bottom);
		}
		else if (align.containsAll(Alignment.TOP)) {
			baseY = Std.int(area.top);
		}

		return baseY;
	}
}