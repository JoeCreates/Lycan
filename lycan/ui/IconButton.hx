package lycan.ui;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfTwo;
import lycan.util.ImageLoader;

class IconButton extends FlxTypedButton<FlxSprite> {
	public function new(x:Float, y:Float, ?graphic:FlxGraphicAsset, ?onClick:Void->Void, iconScale:Float = 1, padding:Int = 0, ?sound:FlxSoundAsset) {
		super(x, y, onClick);
		
		label = new FlxSprite();
			
		if (graphic != null) {
			label.loadGraphic(graphic);
		}
		label.scale.set(iconScale, iconScale);
		label.updateHitbox();
		
		width = label.width;
		height = label.height;
		
		scrollFactor.set(1, 1);
		
		allowSwiping = false;
		maxInputMovement = 15;
		
		makeGraphic(Std.int(width + padding * 2), Std.int(height + padding * 2), FlxColor.TRANSPARENT);
		for (i in [FlxButton.NORMAL, FlxButton.PRESSED, FlxButton.HIGHLIGHT]) {
			labelAlphas[i] = 1;
			labelOffsets[i].set(padding, padding);
			statusAnimations[i] = "normal";
		}
		status = FlxButton.NORMAL;
		updateLabelPosition();
		
		if (sound != null) {
			onUp.sound = FlxG.sound.load(sound);
			#if html5
			onUp.sound.pan = 0.0001; // Hacky workaround for Chrome 44 sound panning bug
			#end
		}
	}
}