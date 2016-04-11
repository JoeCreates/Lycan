package lycan.tests.demo;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lycan.ui.layouts.HBoxLayout;
import lycan.ui.layouts.VBoxLayout;
import lycan.ui.widgets.Label;
import lycan.ui.widgets.LayoutContainer;
import lycan.ui.widgets.LineEdit;
import lycan.util.EditDistanceMetrics;

class EditDistancesDemo extends BaseDemoState {
	private var sourceLineEdit:LineEdit;
	private var targetLineEdit:LineEdit;
	
	private var fastLevenshteinDistance(default, set):Int;
	private var levenshteinDistance(default, set):Int;
	private var damerauLevenshteinDistance(default, set):Int;
	private var jaroDistance(default, set):Float;
	private var jaroWinklerDistance(default, set):Float;
	private var mongeElkanDistance(default, set):Float;
	private var diceCoefficient(default, set):Float;
	
	private var fastLevenshteinText:FlxText;
	private var levenshteinText:FlxText;
	private var damerauLevenshteinText:FlxText;
	private var jaroText:FlxText;
	private var jaroWinklerText:FlxText;
	private var mongeElkanText:FlxText;
	private var diceText:FlxText;
	
	override public function create():Void {
		super.create();
		
		bgColor = FlxColor.GRAY;
		
		var lineEditContainer:LayoutContainer = new LayoutContainer(new HBoxLayout(10), ui);
		lineEditContainer.width = FlxG.width;
		lineEditContainer.height = 100;
		
		var descriptionContainer:LayoutContainer = new LayoutContainer(new VBoxLayout(10), ui);
		descriptionContainer.x = 0;
		descriptionContainer.y = 100;
		descriptionContainer.width = FlxG.width;
		descriptionContainer.height = FlxG.height - 100;
		
		sourceLineEdit = new LineEdit(lineEditContainer);
		sourceLineEdit.textGraphic = cast uiGroup.add(new FlxText(0, 0, 0, "Source", 24));
		sourceLineEdit.signal_textEdited.add(textChanged);
		targetLineEdit = new LineEdit(lineEditContainer);
		targetLineEdit.textGraphic = cast uiGroup.add(new FlxText(0, 0, 0, "Target", 24));
		targetLineEdit.signal_textEdited.add(textChanged);
		
		fastLevenshteinText = new FlxText(0, 0, 0, "", 24);
		levenshteinText = new FlxText(0, 0, 0, "", 24);
		damerauLevenshteinText = new FlxText(0, 0, 0, "", 24);
		jaroText = new FlxText(0, 0, 0, "", 24);
		jaroWinklerText = new FlxText(0, 0, 0, "", 24);
		mongeElkanText = new FlxText(0, 0, 0, "", 24);
		diceText = new FlxText(0, 0, 0, "", 24);
		
		var fastLevLabel = new Label(descriptionContainer);
		fastLevLabel.graphic = cast uiGroup.add(fastLevenshteinText);
		var levLabel = new Label(descriptionContainer);
		levLabel.graphic = cast uiGroup.add(levenshteinText);
		var damerauLabel = new Label(descriptionContainer);
		damerauLabel.graphic = cast uiGroup.add(damerauLevenshteinText);
		var jaroLabel = new Label(descriptionContainer);
		jaroLabel.graphic = cast uiGroup.add(jaroText);
		var jaroWinklerLabel = new Label(descriptionContainer);
		jaroWinklerLabel.graphic = cast uiGroup.add(jaroWinklerText);
		var mongeElkanLabel = new Label(descriptionContainer);
		mongeElkanLabel.graphic = cast uiGroup.add(mongeElkanText);
		var diceLabel = new Label(descriptionContainer);
		diceLabel.graphic = cast uiGroup.add(diceText);
		
		descriptionContainer.updateGeometry();
		lineEditContainer.updateGeometry();
		ui.updateGeometry();
		
		sourceLineEdit.signal_textEdited.dispatch("");
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		lateUpdate(dt);
	}
	
	private function textChanged(result:String):Void {		
		fastLevenshteinDistance = EditDistanceMetrics.levenshtein(sourceLineEdit.text, targetLineEdit.text);
		levenshteinDistance = EditDistanceMetrics.damerauLevenshtein(sourceLineEdit.text, targetLineEdit.text, false);
		damerauLevenshteinDistance = EditDistanceMetrics.damerauLevenshtein(sourceLineEdit.text, targetLineEdit.text, true);
		jaroDistance = EditDistanceMetrics.jaro(sourceLineEdit.text, targetLineEdit.text);
		jaroWinklerDistance = EditDistanceMetrics.jaroWinkler(sourceLineEdit.text, targetLineEdit.text);
		mongeElkanDistance = EditDistanceMetrics.mongeElkan(sourceLineEdit.text, targetLineEdit.text, EditDistanceMetrics.jaro, " ");
		diceCoefficient = EditDistanceMetrics.diceCoefficient(sourceLineEdit.text, targetLineEdit.text, 1);
	}
	
	private function set_fastLevenshteinDistance(d:Int):Int {
		fastLevenshteinText.text = "Fast Levenshtein: " + Std.string(d);
		return this.fastLevenshteinDistance = d;
	}
	
	private function set_levenshteinDistance(d:Int):Int {
		levenshteinText.text = "Regular Levenshtein: " + Std.string(d);
		return this.levenshteinDistance = d;
	}
	
	private function set_damerauLevenshteinDistance(d:Int):Int {
		damerauLevenshteinText.text = "DamerauLevenshtein: " + Std.string(d);
		return this.damerauLevenshteinDistance = d;
	}
	
	private function set_jaroDistance(d:Float):Float {
		jaroText.text = "Jaro: " + Std.string(d);
		return this.jaroDistance = d;
	}
	
	private function set_jaroWinklerDistance(d:Float):Float {
		jaroWinklerText.text = "JaroWinkler: " + Std.string(d);
		return this.jaroWinklerDistance = d;
	}
	
	private function set_mongeElkanDistance(d:Float):Float {
		mongeElkanText.text = "MongeElkan: " + Std.string(d);
		return this.mongeElkanDistance = d;
	}
	
	private function set_diceCoefficient(d:Float):Float {
		diceText.text = "Dice (characters): " + Std.string(d);
		return this.diceCoefficient = d;
	}
}