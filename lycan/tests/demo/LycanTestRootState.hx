package lycan.tests.demo;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import lycan.states.LycanRootState;
import lycan.tests.demo.EasingGalleryDemo;
import lycan.ui.layouts.VBoxLayout;
import lycan.ui.renderer.flixel.FlxTextRenderItem;
import lycan.ui.widgets.ListView;

class LycanTestRootState extends LycanRootState {
	private var menu:ListView;
	public var uiGroup(default, null) = new FlxSpriteGroup();
	
	override public function create():Void {		
		menu = new ListView();
		menu.layout = new VBoxLayout(5);
		menu.width = FlxG.width;
		menu.height = FlxG.height;
		uiRoot.topLevelWidget = menu;
		
		super.create();
		
		// TODO use a macro to generate the list, 'new' the states on opening state not on launch
		// TODO actually write a scrollable list view
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		addLabel(new EasingGalleryDemo(), "Easing Gallery");
		
		menu.updateGeometry();
		
		add(uiGroup);
	}
	
	private function addLabel<T:FlxSubState>(state:T, name:String):Void {
		menu.addLabel(new FlxTextRenderItem(new FlxText(0, 0, 0, name, 32)).addTo(uiGroup), function() {
			openSubState(state);
		});
	}
}