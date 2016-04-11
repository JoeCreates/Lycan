package lycan.ui.widgets.buttons;

import lycan.ui.UIObject;
import flixel.FlxSprite;

// Button that has graphics for when released, hovered or pressed
class PushButton extends Button {
	private var unhoveredGraphic(default, set):FlxSprite;
	private var hoveredGraphic(default, set):FlxSprite;
	private var pushedGraphic(default, set):FlxSprite;
	
	public function new(unhoveredGraphic:FlxSprite, hoveredGraphic:FlxSprite, pushedGraphic:FlxSprite, ?parent:UIObject, ?name:String) {
		super(parent, name);
		this.unhoveredGraphic = unhoveredGraphic;
		this.hoveredGraphic = hoveredGraphic;
		this.pushedGraphic = pushedGraphic;
		graphics.push(unhoveredGraphic);
		graphics.push(hoveredGraphic);
		graphics.push(pushedGraphic);
		
		updateButtonVisibility();
		updateGeometry();
		centerButtonGraphics();
	}
	
	override public function updateGeometry() {
		super.updateGeometry();
		
		var maxWidth:Int = 0;
		var maxHeight:Int = 0;
		
		for (graphic in [unhoveredGraphic, hoveredGraphic, pushedGraphic]) {
			maxWidth = cast Math.max(maxWidth, graphic.width);
			maxHeight = cast Math.max(maxHeight, graphic.height);
		}
		
		width = maxWidth;
		height = maxHeight;
	}
	
	private function updateButtonVisibility():Void {
		if (pressed) {
			unhoveredGraphic.visible = false;
			hoveredGraphic.visible = false;
			pushedGraphic.visible = true;
			return;
		} else if (hovered) {
			unhoveredGraphic.visible = false;
			hoveredGraphic.visible = true;
			pushedGraphic.visible = false;
			return;
		} else {
			unhoveredGraphic.visible = true;
			hoveredGraphic.visible = false;
			pushedGraphic.visible = false;
		}
	}
	
	private function set_unhoveredGraphic(unhoveredGraphic:FlxSprite) {
		return this.unhoveredGraphic = unhoveredGraphic;
	}
	
	private function set_hoveredGraphic(hoveredGraphic:FlxSprite) {
		return this.hoveredGraphic = hoveredGraphic;
	}
	
	private function set_pushedGraphic(pushedGraphic:FlxSprite) {
		return this.pushedGraphic = pushedGraphic;
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