package lycan.ui.widgets.buttons ;

import flixel.FlxSprite;
import lycan.ui.widgets.buttons.Button;

class CheckBox extends Button {
	private var uncheckedGraphic:FlxSprite;
	private var checkedGraphic:FlxSprite;
	private var disabledGraphic:FlxSprite;
	private var checked(default, set):Bool;
	
	public function new(uncheckedGraphic:FlxSprite, checkedGraphic:FlxSprite, disabledGraphic:FlxSprite, ?checked:Bool = false, ?parent:UIObject, ?name:String) {
		super(parent, name);
		this.uncheckedGraphic = uncheckedGraphic;
		this.checkedGraphic = checkedGraphic;
		this.disabledGraphic = disabledGraphic;
		graphics.push(uncheckedGraphic);
		graphics.push(checkedGraphic);
		graphics.push(disabledGraphic);
		
		updateCheckboxVisibility();
		updateGeometry();
		centerButtonGraphics();
		
		this.checked = checked;
		
		signal_clicked.add(handleClick);
	}
	
	override public function updateGeometry() {
		super.updateGeometry();
		
		var maxWidth:Int = 0;
		var maxHeight:Int = 0;
		
		for (graphic in [uncheckedGraphic, checkedGraphic, disabledGraphic]) {
			maxWidth = cast Math.max(maxWidth, graphic.width);
			maxHeight = cast Math.max(maxHeight, graphic.height);
		}
		
		width = maxWidth;
		height = maxHeight;
	}
	
	private function updateCheckboxVisibility():Void {
		if (!enabled) {
			uncheckedGraphic.visible = false;
			checkedGraphic.visible = false;
			disabledGraphic.visible = true;
			return;
		} else if (checked) {
			uncheckedGraphic.visible = false;
			checkedGraphic.visible = true;
			disabledGraphic.visible = false;
			return;
		} else {
			uncheckedGraphic.visible = true;
			checkedGraphic.visible = false;
			disabledGraphic.visible = false;
		}
	}
	
	override private function set_enabled(enabled:Bool):Bool {
		super.set_enabled(enabled);
		updateCheckboxVisibility();
		return enabled;
	}
	
	private function handleClick():Void {
		if (!enabled) {
			return;
		}
		
		checked = !checked;
	}
	
	private function set_checked(checked:Bool):Bool {
		this.checked = checked;
		updateCheckboxVisibility();
		return checked;
	}
}