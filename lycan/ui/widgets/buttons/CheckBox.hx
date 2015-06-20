package lycan.ui.widgets.buttons ;

import lycan.ui.renderer.IRenderItem;
import lycan.ui.widgets.buttons.Button;

class CheckBox extends Button {
	private var uncheckedGraphic:IRenderItem;
	private var checkedGraphic:IRenderItem;
	private var disabledGraphic:IRenderItem;
	private var checked(default, set):Bool;
	
	public function new(uncheckedGraphic:IRenderItem, checkedGraphic:IRenderItem, disabledGraphic:IRenderItem, ?checked:Bool = false, ?parent:UIObject, ?name:String) {
		super(parent, name);
		this.uncheckedGraphic = uncheckedGraphic;
		this.checkedGraphic = checkedGraphic;
		this.disabledGraphic = disabledGraphic;
		buttonGraphics.push(uncheckedGraphic);
		buttonGraphics.push(checkedGraphic);
		buttonGraphics.push(disabledGraphic);
		
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
			maxWidth = cast Math.max(maxWidth, graphic.get_width());
			maxHeight = cast Math.max(maxHeight, graphic.get_height());
		}
		
		width = maxWidth;
		height = maxHeight;
	}
	
	private function updateCheckboxVisibility():Void {
		if (!enabled) {
			uncheckedGraphic.hide();
			checkedGraphic.hide();
			disabledGraphic.show();
			return;
		} else if (checked) {
			uncheckedGraphic.hide();
			checkedGraphic.show();
			disabledGraphic.hide();
			return;
		} else {
			uncheckedGraphic.show();
			checkedGraphic.hide();
			disabledGraphic.hide();
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