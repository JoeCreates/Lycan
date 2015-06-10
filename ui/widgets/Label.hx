package lycan.ui.widgets;

import flixel.text.FlxText;
import lycan.ui.UIObject;

class Label extends Widget {
	public var graphic:FlxText;
	
	public function new(?parent:UIObject, ?name:String) {
		super(parent, name);
	}
	
	public function loadText(text:FlxText) {
		
	}
}