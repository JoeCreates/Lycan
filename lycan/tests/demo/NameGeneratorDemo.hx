package lycan.tests.demo;

import flixel.FlxG;
import flixel.text.FlxText;
import lycan.ui.layouts.AbsoluteLayout;
import lycan.ui.layouts.HBoxLayout;
import lycan.ui.renderer.flixel.FlxDebugRenderItem;
import lycan.ui.renderer.flixel.FlxTextRenderItem;
import lycan.ui.widgets.buttons.PushButton;
import lycan.ui.widgets.LayoutContainer;
import lycan.ui.widgets.LineEdit;
import lycan.util.EditDistanceMetrics;
import lycan.util.namegen.NameGenerator;
import lycan.util.namegen.Names;
import lycan.util.PrefixTrie;

class NameGeneratorDemo extends BaseDemoState {
	private var namesText:FlxText;
	private var similarNameField:LineEdit;
	private var lastGeneratedNames:Array<String>;
	
	override public function create():Void {
		super.create();
		
		ui.layout = new AbsoluteLayout();
		
		var controls = new LayoutContainer(new HBoxLayout(10), ui, "buttons");
		controls.width = FlxG.width;
		controls.height = 200;
		controls.widthHint = FlxG.width;
		controls.heightHint = 200;
		
		var vampireButton = new PushButton(new FlxDebugRenderItem(120, 80).addTo(uiGroup), new FlxDebugRenderItem(100, 60).addTo(uiGroup), new FlxDebugRenderItem(80, 40).addTo(uiGroup));
		var armyButton = new PushButton(new FlxDebugRenderItem(120, 80).addTo(uiGroup), new FlxDebugRenderItem(100, 60).addTo(uiGroup), new FlxDebugRenderItem(80, 40).addTo(uiGroup));
		var journoButton = new PushButton(new FlxDebugRenderItem(120, 80).addTo(uiGroup), new FlxDebugRenderItem(100, 60).addTo(uiGroup), new FlxDebugRenderItem(80, 40).addTo(uiGroup));
		var richButton = new PushButton(new FlxDebugRenderItem(120, 80).addTo(uiGroup), new FlxDebugRenderItem(100, 60).addTo(uiGroup), new FlxDebugRenderItem(80, 40).addTo(uiGroup));
		var clearButton = new PushButton(new FlxDebugRenderItem(120, 80).addTo(uiGroup), new FlxDebugRenderItem(100, 60).addTo(uiGroup), new FlxDebugRenderItem(80, 40).addTo(uiGroup));
		similarNameField = new LineEdit();
		similarNameField.textGraphic = new FlxTextRenderItem(new FlxText(0, 0, 0, "Similar To...", 16)).addTo(uiGroup);
		
		controls.addChild(vampireButton);
		controls.addChild(armyButton);
		controls.addChild(journoButton);
		controls.addChild(richButton);
		controls.addChild(clearButton);
		controls.addChild(similarNameField);
		
		namesText = new FlxText(0, 200, 0, "", 16);
		uiGroup.add(namesText);
		
		ui.updateGeometry();
		controls.updateGeometry();
		
		vampireButton.signal_clicked.add(generateNames.bind(Names.vampireForenames, true));
		armyButton.signal_clicked.add(generateNames.bind(Names.armyForenames, true));
		journoButton.signal_clicked.add(generateNames.bind(Names.journoForenames, true));
		richButton.signal_clicked.add(generateNames.bind(Names.richForenames, true));
		clearButton.signal_clicked.add(function() {
			namesText.text = "Click a button to generate unique names!";
		});
		
		similarNameField.signal_textEdited.add(function(content:String) {
			sortBySimilarity(lastGeneratedNames, content);			
			namesText.text = makeNameText(lastGeneratedNames);
		});
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		lateUpdate(dt);
	}
	
	public function generateNames(data:Array<Name>, generateUniqueOnly:Bool = true):Void {
		var nameGenerator = new NameGenerator(data, 3, 0.005);
		
		var trie = new PrefixTrie();
		
		if(generateUniqueOnly) {
			for (name in data) {
				trie.insert(name.name.toLowerCase());
			}
		}
		
		var uniques:Int = 0;
		var uniqueNames = new Array<String>();
		while (uniques < 100) {
			var name = nameGenerator.generateName(5, 12, "", "");
			if (!trie.find(name)) {
				trie.insert(name);
				uniques++;
				uniqueNames.push(name);
			}
		}
		
		lastGeneratedNames = uniqueNames;
		sortBySimilarity(uniqueNames, similarNameField.text);
		namesText.text = makeNameText(uniqueNames);
	}
	
	private function sortBySimilarity(names:Array<String>, similarTo:String):Void {
		if (similarTo.length <= 0) {
			return;
		}
		
		if (names == null) {
			return;
		}
		
		names.sort(function(x:String, y:String):Int {
			var xSimilarity:Float = EditDistanceMetrics.damerauLevenshtein(x, similarTo);
			var ySimilarity:Float = EditDistanceMetrics.damerauLevenshtein(y, similarTo);
			
			if (xSimilarity > ySimilarity) {
				return 1;
			} else if (xSimilarity < ySimilarity) {
				return -1;
			} else {
				return 0;
			}
		});
	}
	
	private function makeNameText(names:Array<String>):String {
		var text = "";
		var maxLineLength:Int = 60;
		var charCount:Int = 0;
		for (name in names) {
			if (charCount > maxLineLength) {
				text += "\n";
				charCount = 0;
			}
			text += name + ", ";
			charCount += name.length + 2;
		}
		return text;
	}
}