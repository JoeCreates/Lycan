package lycan.util;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class DebugRenderItem extends FlxSprite {
	public var group:FlxSpriteGroup = null;
	
	public function new(w:Int, h:Int, ?color:FlxColor, text:String = "", textSize:Int = 12) {
		super();
		if (color == null) {
			color = FlxColor.fromRGB(Std.int(Math.random() * 255), Std.int(Math.random() * 255), Std.int(Math.random() * 255), 128);
		}
		makeGraphic(w, h, color);
		
		if (text != null && text != "") {
			var textSprite = new FlxText(0, 0, 0, text, textSize);
			stamp(textSprite);
		}
	}
	
	public function addTo(group:FlxSpriteGroup) {
		Sure.sure(this.group == null);
		this.group = group;
		group.add(this);
		return this;
	}
	
	public function removeFrom(group:FlxSpriteGroup) {
		Sure.sure(this.group != null);
		group.remove(this);
		this.group = null;
		return this;
	}
}