package lycan.ui.widgets.buttons;

import flixel.FlxSprite;

// Single-image button
class IconButton extends Button {
	public function new(graphic:FlxSprite, ?parent:UIObject, ?name:String) {
		super(parent, name);
		graphics.push(graphic);
		updateGeometry();
	}
	
	override public function updateGeometry() {
		super.updateGeometry();
		
		width = Std.int(graphics[0].width);
		height = Std.int(graphics[0].height);
	}
}