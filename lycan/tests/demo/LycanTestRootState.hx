package lycan.tests.demo;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lycan.states.LycanRootState;
import lycan.tests.demo.EasingGalleryDemo;
import lycan.ui.layouts.VBoxLayout;
import lycan.ui.widgets.buttons.IconButton;
import lycan.ui.widgets.ListView;

class LycanTestRootState extends LycanRootState {
	private var menu:ListView;
	public var uiGroup(default, null) = new FlxSpriteGroup();
	
	public function new() {
		super();
		persistentDraw = false;
		persistentUpdate = false;
	}
	
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
		// TODO add an option that enters every demo state, takes a screenshot, and returns to the root state
		
		addButton(new EasingGalleryDemo(), "Easing Gallery");
		addButton(new EditDistancesDemo(), "Edit Distances");
		addButton(new LocaleSwitcherDemo(), "Locale Switcher");
		addButton(new NameGeneratorDemo(), "Name Generator");
		addButton(new StringTransformDemo(), "String Transformer");
		addButton(new IntervalTreesDemo(), "Interval Trees");
		addButton(new TimelineDemo(), "Callback Timeline");
		addButton(new ThresholdTriggerDemo(), "Threshold Trigger Demo");
		
		menu.updateGeometry();
		
		add(uiGroup);
	}
	
	private function addButton<T:FlxSubState>(state:T, name:String):Void {
		var text = new FlxText(0, 0, 0, name, 32);
		var button = new IconButton(text, menu);
		for (g in button.graphics) {
			uiGroup.add(g);
		}
		button.signal_clicked.add(function() {
			openSubState(state);
		});
	}
}