package lycan.effects;

import openfl.display.Bitmap;
import openfl.display3D.textures.RectangleTexture;
import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flixel.FlxSprite;
import flixel.addons.display.shapes.FlxShapeLightning;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPool;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.util.helpers.FlxRange;
import lycan.states.LycanState;
import flixel.group.FlxGroup;
import flash.geom.ColorTransform;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flash.display.BitmapDataChannel;

@:tink class LightningZone extends FlxSprite implements IFlxDestroyable {
	@:forward(add, remove) public var group:FlxTypedGroup<Lightning>;
	
	var filter:GlowFilter;
	var filterFrames:FlxFilterFrames;

	public var fade:Bool;
	/** How much alpha fades per second */
	public var fadeRate:Float;
	/** Alternative method of setting fadeRate. Seconds until alpha fades to 0 */
	public var fadeTime(get, set):Float;
	public var enableFilters:Bool = false;
	public var alphaChannel:Null<BitmapDataChannel>;

	var fadeTransform:ColorTransform;
	var fadePixels:BitmapData;
	var fadeBM:openfl.display.Bitmap;
	
	public function new(?width:Int, ?height:Int) {
		super();
		if (width == null) width = FlxG.width;
		if (height == null) width = FlxG.height;
		
		// #if !flash
		// var makeTexture = ()->return BitmapData.fromTexture(FlxG.stage.context3D.createRectangleTexture(width, height, BGRA, true));
		// pixels = makeTexture();
		// //fadePixels = makeTexture();
		// fadePixels = new BitmapData(width, height, true, 0xffff0000);
		// fadeBM = new Bitmap(fadePixels);
		
		
		// #else
		makeGraphic(width, height, 0, true);
		// #end
		
		group = new FlxTypedGroup<Lightning>();
		
		//filter = new GlowFilter(FlxColor.WHITE, 1, 16, 16, 2);
		//filterFrames = FlxFilterFrames.fromFrames(frames, 0, 0, [filter]);
		fadeTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		
		fadeTime = 0.1;
	}
	
	
	override public function draw():Void {
		pixels.lock();
		if (fade) {
			fadeTransform.alphaMultiplier = Math.max(0, 1 - fadeRate * FlxG.elapsed);
			pixels.colorTransform(pixels.rect, fadeTransform);
			// fadePixels.fillRect(fadePixels.rect, 0);
			// fadePixels.draw(pixels, null, null);
			// pixels.fillRect(pixels.rect, 0);
			// pixels.draw(fadeBM, null, fadeTransform);
		} else {
			pixels.fillRect(pixels.rect, 0);
		}
		// pixels.fillRect(pixels.rect, 0);
		// pixels.draw(pixels, null, fadeTransform);
		pixels.unlock();
		frames = frames;
		
		
		for (l in group.members) {
			if (l.active && l.alive) {
				l.drawTo(this);
			}
		}
		
		//TODO this is a workaround for a flixel issue
		//applyToSprite sets sprites graphic to parent of filterFrames, which is null (unless we do this)
		// if (enableFilters) {
		// 	filterFrames.parent = graphic;
		// 	filterFrames.applyToSprite(this, false, true);
		// }
		
		super.draw();
	}
	
	override public function update(dt):Void {
		group.update(dt);
		super.update(dt);
	}

	override public function destroy():Void {
		super.destroy();
		fadeTransform = null;
		filterFrames.destroy();
	}

	private function get_fadeTime():Float {
		return fadeRate > 0 ? 1 / fadeRate : 0;
	}
	
	private function set_fadeTime(t:Float):Float {
		if (t > 0) {
			fadeRate = 1 / t;
		} else {
			fade = false;
		}
		return t;
	}
}