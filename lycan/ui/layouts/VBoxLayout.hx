package lycan.ui.layouts;

import flixel.math.FlxRect;
import lycan.ui.events.UIEvent.ChildEvent;
import lycan.ui.layouts.Layout.Alignment;
import lycan.ui.widgets.Widget;

using lycan.util.BitSet;

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

	}
	
	private inline function layoutOthers(area:FlxRect):Void {

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