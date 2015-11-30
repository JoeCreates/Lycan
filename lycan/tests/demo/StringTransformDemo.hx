package lycan.tests.demo;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import lycan.ui.TweeningTransformingText;
import lycan.util.EditDistanceMetrics;
import lycan.util.StringTransforms;
import flixel.tweens.FlxTween;
import lycan.util.StringTransforms.EditOperation;
import lycan.util.EasingEquations;
import lycan.ui.TransformingText;

using lycan.util.ArrayExtensions;

class StringTransformDemo extends BaseDemoState {
	private var strings:Array<Array<String>> = [
		["Colorless", "Green", "Ideas", "Sleep", "Furiously" ],
		["Le", "Silence", "Vertébral", "Indispose", "La", "Voile", "Licite"],
		["Two wrongs don't make a right", "The pen is mightier than the sword", "When in Rome, do as the Romans", "The squeaky wheel gets the grease", "No man is an island", "Better late than never", "Birds of a feather flock together", "There's no place like home", "The early bird catches the worm", "Never look a gift horse in the mouth", "A watched pot never boils", "Cleanliness is next to godliness", "Practice makes perfect", "Easy come, easy go", "There's no time like the present"],
		["Severe", "Municipal", "Jazz", "Hot", "Racial", "Archbishop"],
		["A chain is only as strong as its weakest link", "A house is not a home", "A miss is as good as a mile", "A penny saved is a penny earned"],
		["A leopard cannot change its spots", "A stitch in time saves nine", "A word to the wise is enough", "Actions speak louder than words", "Enough is enough", "First things first", "Keep your chin up", "Knowledge is power", "Out of sight, out of mind"],
		["0xDEADBEEF", "0xB105F00D", "0xBADA55", "0xBAADF00D", "0xCAFEBABE", "0xD15EA5E", "0xDEADDEAD", "0xDEADC0DE"]
	];
	private var operationsText:FlxText;
	private var arrayIndex:Int;
	private var index:Int;
	private var current:String;
	private var target:String;
	private var transformingText:TweeningTransformingText;
	private var button:FlxButton;
	
	private var continueButton:FlxButton;
	
	private var timer:FlxTimer;
	
	override public function create():Void {
		super.create();
		
		operationsText = new FlxText(FlxG.width * 0.05, FlxG.height * 0.1, 0, "", 10);
		add(operationsText);
		
		arrayIndex = 0;
		index = 0;
		var source = getNext();
		var target = getNext();
		
		var matrix = EditDistanceMetrics.damerauLevenshteinMatrix(source, target, false);
		var ops = StringTransforms.optimalLevenshteinPath(source, target, matrix);
		
		transformingText = new TweeningTransformingText(0, 0, source, ops);
		transformingText.screenCenter();
		add(transformingText);
		
		transformingText.signal_operationHandled.add(function(e:EditOperation):Void {
			transformingText.screenCenter(FlxAxes.X);
			
			if (operationsText.height >= FlxG.height * 0.8) {
				operationsText.text = "";
			}
			
			operationsText.text += Std.string(e) + "\n";
		});
		transformingText.signal_operationsHandled.add(function():Void {
			continueButton.visible = true;
		});
		
		button = new FlxButton(0, FlxG.height * 0.8, "Change strings", function():Void {
			arrayIndex++;
			arrayIndex %= strings.length;
		});
		add(button);
		button.screenCenter(FlxAxes.X);
		
		continueButton = new FlxButton(0, FlxG.height * 0.7, "Continue", function():Void {
			operationsText.text = "";
			startTransform();
			continueButton.visible = false;
		});
		continueButton.visible = false;
		continueButton.screenCenter(FlxAxes.X);
		add(continueButton);
		
		startTransform();
	}
	
	private inline function getNext():String {
		return strings[arrayIndex].circularIndex(index++);
	}
	
	private function startTransform():Void {
		var source = transformingText.getText();
		var target = getNext();
		var matrix = EditDistanceMetrics.damerauLevenshteinMatrix(source, target, false);
		var ops = StringTransforms.optimalLevenshteinPath(source, target, matrix);
		transformingText.retarget(ops);
		transformingText.screenCenter(FlxAxes.X);
		
		if (timer != null) {
			timer.cancel();
		}
		timer = new FlxTimer().start(0.1, function(t:FlxTimer):Void {
			transformingText.pump();
		}, 0);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		lateUpdate(dt);
	}
}

// Text that transforms from one string to another by executing a series of edit operations, and tweens nicely too
// NOTE doesn't queue or manage tweens, so text can get misaligned in some circumstances
class TweeningTransformingText extends TransformingText {
	public function new(x:Float, y:Float, initialText:String, operations:Array<EditOperation>, size:Int = 24, spacing:Float = 0, font:String = "fairfax") {
		super(x, y, initialText, operations, size, spacing, font);
	}
	
	override private function keep(s:String, idx:Int):Void {
		var letter = letters[idx];
		FlxTween.tween(letter, { y: letter.y - 20 }, 1, { ease: EaseSine.inOutSine, type: FlxTween.PINGPONG, onComplete: function(t:FlxTween):Void {
			if (t.executions == 2) {
				t.cancel();
			}
		}});
	}
	
	override private function insert(s:String, src:Int, target:Int):Void {
		var letter = getLetter(s);
		letter.alpha = 0;
		letter.y += 100;
		letters.insert(target + 1, letter);
		FlxTween.tween(letter, { y : letter.y - 100, alpha: 1 }, 2, { ease: EaseExpo.outInExpo });
	}
	
	override private function delete(s:String, idx:Int):Void {
		var letters = letters.splice(idx, 1);
		var letter = letters[0];
		FlxTween.tween(letter, { y : letter.y - 100, alpha: 0 }, 2, { ease: EaseExpo.outInExpo, onComplete: function(t:FlxTween):Void {
			remove(letter, true);
		}});
	}
	
	override private function substitute(r:String, i:String, idx:Int):Void {
		var oldLetter = letters[idx];
		FlxTween.tween(oldLetter, { y : oldLetter.y - 100, alpha: 0 }, 2, { ease: EaseExpo.outInExpo, onComplete: function(t:FlxTween):Void {
			remove(oldLetter, true);
		}});
		
		var newLetter = getLetter(i);
		newLetter.alpha = 0;
		newLetter.y += 100;
		letters[idx] = newLetter;
		FlxTween.tween(newLetter, { y : newLetter.y - 100, alpha: 1 }, 2, { ease: EaseExpo.outInExpo });
	}
	
	override private function layoutLetters():Void {
		var cumulativeX:Float = 0;
		for (letter in letters) {
			letter.x = x + cumulativeX;
			cumulativeX += letter.width + spacing;
		}
	}
}