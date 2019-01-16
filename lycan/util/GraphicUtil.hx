package lycan.util;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.ByteArray;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
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
import openfl.display.Graphics;
import openfl.display.Sprite;

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
			//spr.pixels.readable = false;
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
	 * //TODO shader version for real time stuff
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
	
	public static function scaleBitmapData(bitmapData:BitmapData, scale:Float):BitmapData {
		scale = Math.abs(scale);
		
		var width:Int = Std.int(bitmapData.width * scale);
		var height:Int = Std.int(bitmapData.height * scale);
		var transparent:Bool = bitmapData.transparent;
		var result:BitmapData = new BitmapData(width, height, transparent);
		
		var matrix:Matrix = new Matrix();
		matrix.scale(scale, scale);
		result.draw(bitmapData, matrix);
		
		return result;
	}
	
	public static function makePlaceholderGraphic(spr:FlxSprite, name:String, width:Int, height:Int,
		?anims:Array<{name:String, frameCount:Int}>, color:FlxColor = FlxColor.WHITE, ?frameRate:Float):Void
	{
		var frameCount:Int = 0;
		if (anims == null) anims = [{name: "", frameCount: 1}];
		for (a in anims) {
			frameCount += a.frameCount;
		}
		if (frameCount == 0) frameCount = 1;
		
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
		
		if (frameRate != null) {
			var curFrame:Int = 0;
			for (a in anims) {
				spr.animation.add(a.name, [for (i in curFrame...curFrame + a.frameCount) i], cast frameRate, true);
				curFrame += a.frameCount;
			}
		}
	}
	
	public static function makeArrowBitmap(triangleWidth:Float, triangleLength:Float, lineWidth:Float, lineLength:Float,
		solidTriangle:Bool = true, triangleInset:Float = 0, color:FlxColor = FlxColor.WHITE, ?lineStyle:LineStyle, ?drawStyle:DrawStyle):BitmapData
	{
		if (lineStyle != null) lineStyle.color = color;
		
		var tempSprite:FlxSprite = new FlxSprite();
		var width:Float = Math.max(triangleWidth, lineWidth);
		var height:Float = triangleLength + lineLength;
		var mid:Float = width / 2;
		var triangleX:Float = mid - triangleWidth / 2;
		var lineX:Float = mid - lineWidth / 2;
		if (!solidTriangle && triangleInset == 0) triangleInset = triangleLength; 
		tempSprite.makeGraphic(Std.int(width), Std.int(height), 0, true);
		
		// Draw triangle
		var triPoints:Array<FlxPoint> = [
			FlxPoint.get(triangleX, triangleLength),
			FlxPoint.get(mid, 0),
			FlxPoint.get(triangleX + triangleWidth, triangleLength)
		];
		if (triangleInset > 0) triPoints.push(FlxPoint.get(mid, triangleLength - triangleInset));
		if (solidTriangle) triPoints.push(triPoints[0]);
		
		//var mat:Matrix = new Matrix();
		//mat.identity();
		//mat.rotate();
		
		var quality = FlxG.stage.quality;
		FlxG.stage.quality = LOW;
		
		FlxSpriteUtil.drawPolygon(tempSprite, triPoints, solidTriangle ? color : 0, lineStyle, {smoothing: false});
		
		FlxG.stage.quality = quality;
		
		for (p in triPoints) p.put();
		
		// Draw line
		if (lineWidth > 0 || lineLength > 0) {
			trace("Make rect: " + lineX + ", " + (triangleLength - triangleInset) + " " + lineWidth);
			FlxSpriteUtil.drawRect(tempSprite, lineX, triangleLength - triangleInset, lineWidth,
				lineLength + triangleInset, color, lineStyle, drawStyle);
		}
		
		var out:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0);
		out.draw(tempSprite.pixels);
		
		tempSprite.destroy();
		
		return out;
	}
	
}