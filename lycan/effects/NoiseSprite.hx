package lycan.effects;

import flixel.FlxSprite;
import openfl.display.BitmapData;
import flixel.FlxG;

class NoiseSprite extends FlxSprite {
	
	private var noiseAnimationName:String;
	
	public function new(width:Float = 100, height:Float = 100, minValue:Int = 20, maxValue:Int = 190, channelSize:Int = 7, grayScale:Bool = false, frames:Int = 5, frameRate:Int = 20, name:String = "noise") {
		super(0, 0);
		this.width = width;
		this.height = height;
		addNoiseAnimation(this, minValue, maxValue, channelSize, grayScale, frames, frameRate, name);
		noiseAnimationName = name;
	}
	
	public function play() {
		animation.play(noiseAnimationName);
	}
	public function stop() {
		animation.stop();
	}
	
	public static function addNoiseAnimation(noiseSprite:FlxSprite, minValue:Int = 20, maxValue:Int = 190, channelSize:Int = 7, grayScale:Bool = false, frames:Int = 5, frameRate:Int = 20, name:String = "noise"):FlxSprite {
		var noiseFrames:BitmapData = new BitmapData(Std.int(noiseSprite.width * frames), Std.int(noiseSprite.height), false);
		noiseFrames.noise(FlxG.random.int(), minValue, maxValue, channelSize, grayScale);
		noiseSprite.loadGraphic(noiseFrames, true, Std.int(noiseSprite.width), Std.int(noiseSprite.height), false,
			"lycan.effects.noiseSprite" + Std.int(noiseSprite.width) + "," + Std.int(noiseSprite.height) + "," + minValue + "," +
			maxValue + "," + grayScale + "," + channelSize + "," + frames);
		noiseSprite.animation.add(name, [for (i in 0...frames) i], frameRate);
		noiseSprite.animation.play(name);
		return noiseSprite;
	}
}