package lycan.effects;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;

class FlashSprite extends FlxSprite {
	private var fadeTime:Float = 0;
	
	public function new(x:Float = 0, y:Float = 0, ?graphic:FlxGraphicAsset) {
		super(x, y, graphic);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (alpha > 0) {
			if (fadeTime == 0) {
				alpha = 0;
			} else {
				alpha -= dt / fadeTime;
				if (alpha < 0) alpha = 0;
			}
		}
		
	}
	
	public function flash(fadeTime:Float = 0.2, alpha:Float = 1):Void {
		this.alpha = alpha;
		this.fadeTime = fadeTime / alpha;
	}
}