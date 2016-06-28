package lycan.ui.layouts;

import flixel.math.FlxRect;
import lycan.ui.events.UIEvent.ChildEvent;
import lycan.ui.layouts.Layout.Alignment;
import lycan.ui.widgets.Widget;

using lycan.util.structure.container.BitSet;

enum VBoxLayoutDirection {
	TOP_TO_BOTTOM;
	BOTTOM_TO_TOP;
}

class VBoxLayout extends BoxLayout {
	private var direction:VBoxLayoutDirection;

	public function new(spacing:Int, ?layoutDirection:VBoxLayoutDirection, alignment:Int = Alignment.CENTER) {
		super(spacing);

		if (layoutDirection == null) {
			layoutDirection = TOP_TO_BOTTOM;
		}
		direction = layoutDirection;
		align |= alignment;
	}

	override public function update():Void {
		super.update();

		var area:FlxRect = owner.borderRect();

		if (align.containsAll(Alignment.VERTICAL_CENTER)) {
			layoutVerticalCentered(area);
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

	private inline function layoutVerticalCentered(area:FlxRect):Void {
		var childrenHeight:Float = 0;
		for (child in owner.children) {
			var c:Widget = cast child;
			childrenHeight += c.outerRect().height;
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

		var totalHeight:Float = childrenHeight + totalSpacing;
		var baseX = getBaseX(area);
		var baseY = area.top + area.height / 2 - totalHeight / 2;

		for (child in owner.children) {
			var c:Widget = cast child;
			baseY += spacing;
			c.y = Math.round(baseY) + Std.int((c.marginTop + c.marginBottom) / 2); // TODO where does the extra margin addition come from...? Probably a bug...
			baseY += c.outerRect().height;

			if(align.containsAll(Alignment.LEFT)) {
				c.x = Std.int(baseX - c.width);
			} else if (align.containsAll(Alignment.HORIZONTAL_CENTER)) {
				c.x = Std.int(baseX - c.width / 2);
			} else if (align.containsAll(Alignment.RIGHT)) {
				c.x = Std.int(baseX);
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
		else if (align.containsAll(Alignment.HORIZONTAL_CENTER)) {
			baseX = Std.int(area.left + area.width / 2);
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