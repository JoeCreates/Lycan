package lycan.util;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.ByteArray;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.geom.Rectangle;

class GraphicUtil {
	
	static var pointZero:Point = new Point();
	
	/**
	 * Draws a camera onto a FlxSprite
	 * On native, camera's which are not in FlxG.cameras need to have clearDrawStack, canvas.graphics.clear
	 * called prior to drawing the objects on the camera, and render after
	 * @param	spr
	 * @param	camera
	 */
	public static function drawCamera(spr:FlxSprite, camera:FlxCamera):Void {
		if (FlxG.renderBlit) {
			spr.pixels.copyPixels(camera.buffer, camera.buffer.rect, pointZero);
			spr.dirty = true;
		} else {
			spr.pixels.draw(camera.canvas);
		}
	}
	
	public static function createTileSprite(asset:FlxGraphicAsset, tileWidth:Int, tileHeight:Int):FlxSprite {
		var sprite:FlxSprite = new FlxSprite();
		var graph:FlxGraphic = FlxG.bitmap.add(asset);
		sprite.frames = FlxTileFrames.fromGraphic(graph, FlxPoint.weak(tileWidth, tileHeight));
		return sprite;
	}
	
	/**
	 * Masks the `source` BitmapData (in place) using alpha data from `alphaMask`.
	 * 
	 * Note: `source` and `alphaMask` must be of the same size.
	 * 
	 * @param	source		BitmapData to be masked.
	 * @param	alphaMask	BitmapData to be used as mask.
	 * @param	copyAlpha	If true the alpha value of `alphaMask` will be copied over to `source`.
	 */
	public static function applyAlphaMask(source:BitmapData, alphaMask:BitmapData, copyAlpha:Bool = false):Void {
		var sourceRect = source.rect;
		var sourceBytes:ByteArray = source.getPixels(sourceRect);
		var alphaMaskBytes:ByteArray = alphaMask.getPixels(sourceRect);
		
		sourceBytes.position = 0;
		alphaMaskBytes.position = 0;
		
		var nPixels:Int = Std.int(sourceRect.width * sourceRect.height);
		var sourceAlpha:Int = 0;
		var maskAlpha:Int = 0;
		var alphaIdx:Int = 0;
		
		for (idx in 0...nPixels) {
			alphaIdx = idx << 2;
			maskAlpha = alphaMaskBytes[alphaIdx];
			sourceAlpha = sourceBytes[alphaIdx];
			sourceBytes[alphaIdx] = copyAlpha ? maskAlpha : sourceAlpha * (maskAlpha > 0 ? 1 : 0);
		}
		
		source.setPixels(sourceRect, sourceBytes);
	}
	
	
	public static function makePlaceholderGraphic(spr:FlxSprite, name:String, width:Int, height:Int,
		anims:Array<{name:String, frameCount:Int}>, color:FlxColor = FlxColor.WHITE):Void
	{
		var frameCount:Int = 0;
		for (a in anims) {
			frameCount += a.frameCount;
		}
		
		var bitmap:BitmapData = new BitmapData(width * frameCount, height, true, color);
		spr.loadGraphic(bitmap, frameCount > 1, width, height);
		
		var txt:TextField = new TextField();
		txt.defaultTextFormat = new TextFormat("Verdana", 9, color);
		txt.text = "";		
		
		var mat:Matrix = new Matrix(0, 0, 0, 0, 0, 0);
		mat.identity();
		mat.translate(2, 2);
		var rect:Rectangle = new Rectangle(1, 1, width - 2, height - 2);
		var bgColor:FlxColor = color.getDarkened(0.7);
		for (a in anims) {
			for (i in 0...a.frameCount) {
				txt.text = name + "\n" + a.name + "["+ i + "]";
				bitmap.fillRect(rect, bgColor);
				bitmap.draw(txt, mat, null, null, rect);
				mat.translate(width, 0);
				rect.x += width;
			}
		}
	}
	
}