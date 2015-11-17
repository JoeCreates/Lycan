package lycan.tests.demo;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import lycan.util.EditDistanceMetrics;
import lycan.util.StringTransforms;

using lycan.util.ArrayExtensions;

class StringTransformDemo extends BaseDemoState {
	private var strings:Array<String> = [ "Colorless", "Green", "Ideas", "Sleep", "Furiously" ];
	private var index:Int;
	private var current:String;
	private var target:String;
	
	private var text:Array<FlxText> = new Array<FlxText>();
	
	override public function create():Void {
		super.create();
		
		var source = "Democrat";
		var target = "Republican";
		var text = [ "D", "e", "m", "o", "c", "r", "a", "t" ];
		
		/*
		var source = "Republican";
		var target = "Democrat";
		var text = [ "R", "e", "p", "u", "b", "l", "i", "c", "a", "n" ];
		*/
		
		var matrix = EditDistanceMetrics.damerauLevenshteinMatrix(source, target, false);
		var ops = StringTransforms.optimalLevenshteinPath(source, target, matrix);
		
		for (op in ops) {
			switch(op) {
				case EditOperation.DELETION(s, i):
					trace("Delete element " + s + " at index " + i);
					text[i] = "#";
				case EditOperation.INSERTION(s, source, target):
					trace("Insert element " + s + " at index " + target + " from " + source);
					text.insert(target + 1, s); // TODO will short -> long strings or vice versa insert in the wrong places ever? also TODO use the + 1 in the transform algorithm or not?
				case EditOperation.KEEP(s, source):
					trace("Keep element " + s + " at index " + source);
				case EditOperation.SUBSTITUTION(remove, insert, idx):
					trace("Remove element " + remove + " and replace it with " + insert + " at index " + idx);
					text[idx] = insert;
			}
			trace(text.toString());
		}
		
		trace(text.toString());
		
		index = 0;
	}
	
	private inline function getNext():String {
		return strings.circularIndex(index++);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		lateUpdate(dt);
	}
}