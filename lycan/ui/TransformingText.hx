package lycan.ui;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import lycan.util.StringTransforms.EditOperation;
import msignal.Signal.Signal0;
import msignal.Signal.Signal1;

class TransformingText extends FlxTypedSpriteGroup<TransformingLetter> {
	private var letters:Array<TransformingLetter>;
	private var textSize:Int;
	private var operations:Array<EditOperation>;
	private var spacing:Float;
	
	public var signal_operationsHandled = new Signal0();
	public var signal_operationHandled = new Signal1<EditOperation>();
	
	public function new(x:Float, y:Float, initialText:String, operations:Array<EditOperation>, size:Int = 24, spacing:Float = 0, font:String = "fairfax") {
		super();
		letters = new Array<TransformingLetter>();
		this.textSize = size;
		this.operations = operations;
		this.spacing = spacing;
		
		for (i in 0...initialText.length) {
			letters.push(getLetter(initialText.charAt(i)));
		}
	}
	
	public function run(time:Float):Void {
		var timePerLetter:Float = time / operations.length;
		
		for (i in 0...operations.length) {
			var t:FlxTimer = new FlxTimer();
			
			t.start(timePerLetter * i, function(t:FlxTimer):Void {
				handle(operations[i]);
			}, 1);
		}
		
		var t:FlxTimer = new FlxTimer();
		
		t.start(time + 0.05, function(t:FlxTimer):Void {
			signal_operationsHandled.dispatch();
		}, 1);
	}
	
	public function retarget(ops:Array<EditOperation>):Void {
		operations = ops;
	}
	
	public function getText():String {
		var s:String = "";
		for (letter in letters) {
			s += letter.text;
		}
		return s;
	}
	
	private function handle(e:EditOperation):Void {
		switch(e) {
			case EditOperation.DELETION(s, idx):
				delete(s, idx);
			case EditOperation.INSERTION(s, src, target):
				insert(s, src, target);
			case EditOperation.KEEP(s, idx):
				keep(s, idx);
			case EditOperation.SUBSTITUTION(r, i, idx):
				if(i.length != 0) {
					substitute(r, i, idx);
				} else {
					delete(r, idx);
				}
			default:
				throw "Unhandled string edit operation encountered";
		}
		
		signal_operationHandled.dispatch(e);
		layoutLetters();
	}
	
	private function keep(s:String, idx:Int):Void {
		//trace("Keep element " + s + " at index " + idx);
	}
	
	private function insert(s:String, src:Int, target:Int):Void {
		//trace("Insert element " + s + " at index " + target + " from " + src);
		letters.insert(target + 1, getLetter(s));
	}
	
	private function delete(s:String, idx:Int):Void {
		//trace("Delete element " + s + " at index " + idx);
		var letter = letters.splice(idx, 1);
		remove(letter[0], true);
	}
	
	private function substitute(r:String, i:String, idx:Int):Void {
		//trace("Remove element " + r + " and replace it with " + i + " at index " + idx);
		remove(letters[idx], true);
		//trace("Num letters: " + letters.length);
		letters[idx] = getLetter(i);
	}
	
	private function getLetter(letter:String):TransformingLetter {
		var txt = new TransformingLetter(letter, textSize);
		add(txt);
		return txt;
	}
	
	private function layoutLetters():Void {
		var cumulativeX:Float = 0;
		for (letter in letters) {
			letter.x = x + cumulativeX;
			cumulativeX += letter.width + spacing;
		}
	}
	
	override public function destroy():Void {
		for (item in group) {
			item.destroy();
		}
		group.clear();
		super.destroy();
	}
}

class TransformingLetter extends FlxText {
	public function new(char:String, size:Int = 24, font:String = "fairfax") {
		super(0, 0, 0, char, size);
		this.font = font;
	}
}