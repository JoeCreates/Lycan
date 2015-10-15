package lycan.tests.demo;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lycan.states.LycanRootState;
import lycan.tests.demo.EasingGalleryDemo;
import lycan.ui.layouts.VBoxLayout;
import lycan.ui.renderer.flixel.FlxTextRenderItem;
import lycan.ui.widgets.buttons.PushButton;
import lycan.ui.widgets.ListView;
import lycan.util.EditDistanceMetrics;

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
		
		bgColor = FlxColor.GRAY;
		
		// TODO use a macro to generate the list, 'new' the states on opening state not on launch
		// TODO actually write a scrollable list view
		addButton(new EasingGalleryDemo(), "Easing Gallery");
		addButton(new EditDistancesDemo(), "Edit Distances");
		addButton(new LocaleSwitcherDemo(), "Locale Switcher");
		
		menu.updateGeometry();
		
		add(uiGroup);
		
		trace(EditDistanceMetrics.levenshtein("rosettacode", "raisethysword"));
		trace(EditDistanceMetrics.damerauLevenshtein("rosettacode", "raisethysword"));
	}
	
	private function addButton<T:FlxSubState>(state:T, name:String):Void {
		var text = new FlxText(0, 0, 0, name, 32);
		var button = new PushButton(new FlxTextRenderItem(text).addTo(uiGroup), new FlxTextRenderItem(text).addTo(uiGroup), new FlxTextRenderItem(text).addTo(uiGroup), menu);
		button.signal_clicked.add(function() {
			openSubState(state);
		});
	}
}