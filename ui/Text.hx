package lycan.ui ;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class Text extends FlxText {

	var tween:FlxTween;
	
	public function new(y:Float, size:Float = 24, font:String = "fairfax") {
		super(0, y, FlxG.width, "", size);
		this.font = font;
		scrollFactor.set(0, 0);
		alignment = "center";
		alpha = 0;
	}
	
	public function showTimed(?text:String, time:Float = 2.5):Void {
		show(text);
		new FlxTimer().start(time, function(timer:FlxTimer) { hide(); } );
	}
	
	public function show(?text:String, time:Float = 1.5 ):Void {
		if (text != null) {
			this.text = text;
		}
		
		if (tween != null) tween.cancel();
		
		alpha = 0;
		
		tween = FlxTween.tween(this, { alpha: 1 }, time );
	}
	
	public function hide(time:Float = 1.5):Void {
		if (tween != null) tween.cancel();
		tween = FlxTween.tween(this, { alpha: 0 }, time );
	}
	
}