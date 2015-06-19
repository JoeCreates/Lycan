package lycan.ui.widgets;

import lycan.ui.renderer.IRenderItem;
import lycan.ui.UIObject;

// Button that has graphics for when released, hovered or pressed
class PushButton extends Button {
	private var unhoveredGraphic(default, set):IRenderItem;
	private var hoveredGraphic(default, set):IRenderItem;
	private var pushedGraphic(default, set):IRenderItem;
	
	public function new(unhoveredGraphic:IRenderItem, hoveredGraphic:IRenderItem, pushedGraphic:IRenderItem, ?parent:UIObject, ?name:String) {
		super(parent, name);
		this.unhoveredGraphic = unhoveredGraphic;
		this.hoveredGraphic = hoveredGraphic;
		this.pushedGraphic = pushedGraphic;
		updateButtonVisibility();
		updateGeometry();
		centerButtonGraphics();
	}
	
	override public function updateGeometry() {
		super.updateGeometry();
		
		var maxWidth:Int = 0;
		var maxHeight:Int = 0;
		
		for (graphic in [unhoveredGraphic, hoveredGraphic, pushedGraphic]) {
			maxWidth = cast Math.max(maxWidth, graphic.get_width());
			maxHeight = cast Math.max(maxHeight, graphic.get_height());
		}
		
		width = maxWidth;
		height = maxHeight;
	}
	
	private function centerButtonGraphics():Void {
		for (graphic in [unhoveredGraphic, hoveredGraphic, pushedGraphic]) {
			graphic.set_x(x + cast ((width - graphic.get_width()) / 2));
			graphic.set_y(y + cast ((height - graphic.get_height()) / 2));
		}
	}
	
	private function updateButtonVisibility():Void {
		if (pressed) {
			unhoveredGraphic.hide();
			hoveredGraphic.hide();
			pushedGraphic.show();
			return;
		} else if (hovered) {
			unhoveredGraphic.hide();
			hoveredGraphic.show();
			pushedGraphic.hide();
			return;
		} else {
			unhoveredGraphic.show();
			hoveredGraphic.hide();
			pushedGraphic.hide();
		}
	}
	
	private function set_unhoveredGraphic(unhoveredGraphic:IRenderItem) {
		return this.unhoveredGraphic = unhoveredGraphic;
	}
	
	private function set_hoveredGraphic(hoveredGraphic:IRenderItem) {
		return this.hoveredGraphic = hoveredGraphic;
	}
	
	private function set_pushedGraphic(pushedGraphic:IRenderItem) {
		return this.pushedGraphic = pushedGraphic;
	}
	
	override private function set_x(x:Int):Int {
		super.set_x(x);
		centerButtonGraphics();
		return x;
	}
	
	override private function set_y(y:Int):Int {
		super.set_y(y);
		centerButtonGraphics();
		return y;
	}
	
	override private function set_width(width:Int):Int {
		super.set_width(width);
		centerButtonGraphics();
		return width;
	}
	
	override private function set_height(height:Int):Int {
		super.set_height(height);
		centerButtonGraphics();
		return height;
	}
	
	override private function set_hovered(hovered:Bool):Bool {
		super.set_hovered(hovered);
		updateButtonVisibility();
		return hovered;
	}
	
	override private function set_pressed(pressed:Bool):Bool {
		super.set_pressed(pressed);
		updateButtonVisibility();
		return pressed;
	}
}