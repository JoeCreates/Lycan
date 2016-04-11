package lycan.tests.demo;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import lycan.util.noise.Perlin;

using lycan.util.ArrayExtensions;

class NoiseDemo extends BaseDemoState {
	private var noise:FlxSprite;
	private var perlin:Perlin;
	
	override public function create():Void {		
		super.create();
		
		noise = new FlxSprite();
		noise.makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
		
		perlin = new Perlin();
	}
	
	public function fill(sprite:FlxSprite):Void {
		var data = sprite.getFlxFrameBitmapData();
		
		// TODO
		perlin.noise2d(0, 0);
		
		//data.setPixel32();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		lateUpdate(dt);
	}
}