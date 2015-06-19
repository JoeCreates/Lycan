package lycan.ui.widgets ;

import lycan.ui.renderer.IRenderItem;

class CheckBox extends Button {
	private var uncheckedGraphic:IRenderItem;
	private var checkedGraphic:IRenderItem;
	private var disabledGraphic:IRenderItem;
	
	private var checked:Bool = false;
	
	public function new(uncheckedGraphic:IRenderItem, checkedGraphic:IRenderItem, disabledGraphic:IRenderItem, ?parent:UIObject, ?name:String) {
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
		
		trace("Checkbox handling click");
		
		checked = !checked;
		updateCheckboxVisibility();
	}
}