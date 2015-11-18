package lycan.tests.demo;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxTimer;
import lycan.util.EditDistanceMetrics;
import lycan.util.StringTransforms;
import lycan.ui.TransformingText;
import flixel.FlxG;
import flixel.util.FlxAxes;

using lycan.util.ArrayExtensions;

class StringTransformDemo extends BaseDemoState {
	private var strings:Array<Array<String>> = [
		["Colorless", "Green", "Ideas", "Sleep", "Furiously" ],
		["Le", "Silence", "Vertébral", "Indispose", "La", "Voile", "Licite"],
		["Severe", "Municipal", "Jazz", "Hot", "Racial", "Archbishop"],
		["A chain is only as strong as its weakest link", "A house is not a home", "A miss is as good as a mile", "A penny saved is a penny earned"],
		["A leopard cannot change its spots", "A stitch in time saves nine", "A word to the wise is enough", "Actions speak louder than words", "Enough is enough", "First things first", "Keep your chin up", "Knowledge is power", "Out of sight, out of mind"],
		["0xDEADBEEF", "0xB105F00D", "0xBADA55", "0xBAADF00D", "0xCAFEBABE", "0xD15EA5E", "0xDEADDEAD", "0xDEADC0DE"]
	];
	private var arrayIndex:Int;
	private var index:Int;
	private var current:String;
	private var target:String;
	private var transformingText:TransformingText;
	private var button:FlxButton;
	
	override public function create():Void {
		super.create();
		
		arrayIndex = 0;
		index = 0;
		var source = getNext();
		var target = getNext();
		
		var matrix = EditDistanceMetrics.damerauLevenshteinMatrix(source, target, false);
		var ops = StringTransforms.optimalLevenshteinPath(source, target, matrix);
		
		transformingText = new TransformingText(0, 0, source, ops);
		add(transformingText);
		
		transformingText.signal_operationsHandled.add(startTransform);
		transformingText.signal_operationHandled.add(function(e:EditOperation):Void {
			transformingText.screenCenter();
		});
		transformingText.run(3);
		
		button = new FlxButton(0, FlxG.height * 0.8, "Change strings", function():Void {
			arrayIndex++;
			arrayIndex %= strings.length;
		});
		add(button);
		button.screenCenter(FlxAxes.X);
	}
	
	private inline function getNext():String {
		return strings[arrayIndex].circularIndex(index++);
	}
	
	private function startTransform():Void {
		new FlxTimer().start(1, function(t:FlxTimer):Void {
			var source = transformingText.getText();
			var target = getNext();
			var matrix = EditDistanceMetrics.damerauLevenshteinMatrix(source, target, false);
			var ops = StringTransforms.optimalLevenshteinPath(source, target, matrix);
			transformingText.retarget(ops);
			transformingText.run(3);
			transformingText.screenCenter();
		}, 1);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		lateUpdate(dt);
	}
}