package lycan.tests.demo;

import lycan.ui.layouts.VBoxLayout;
import lycan.ui.widgets.TimelineControls;

class TimelineDemo extends BaseDemoState {
	private var timelineControls:TimelineControls;
	
	override public function create():Void {
		super.create();
		
		ui.layout = new VBoxLayout(10);
		
		//timelineControls = new TimelineControls(timeline, uiGroup, ui, "timelineControls");
		//timelineControls.x = 150;
		//timelineControls.y = 140;
		//timelineControls.width = 500;
		//timelineControls.height = 300;
		
		ui.updateGeometry(); // TODO remove once propagating events properly
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		//timelineControls.update(dt);
		
		lateUpdate(dt);
	}
}