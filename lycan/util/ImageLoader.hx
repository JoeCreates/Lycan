package lycan.util;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.Assets;

// TODO for localization asset paths will need substituting. Could do that here or elsewhere...
// TODO assumes png and json assets
class ImageLoader {
	/* Whether to use packed textures or not */
	private static var useTexturePacker:Bool = false;
	
	private static var atlasImagePath:String = "assets/images/sheets/";
	private static var atlasDataPath:String = "assets/data/sheets/";
	
	/* Handles for all the loaded atlas textures */
	private static var atlases:Array<FlxAtlasFrames> = new Array<FlxAtlasFrames>();
	
	public static function loadAtlas(filename:String):FlxAtlasFrames {
		var frames = FlxAtlasFrames.fromTexturePackerJson(atlasImagePath + filename + ".png", Assets.getText(atlasDataPath + filename + ".json"));
		atlases.push(frames);
		return frames;
	}
	
	public static function get(?x:Float, ?y:Float, assetPath:String):FlxSprite {
		if (x == null) {
			x = 0;
		}
		if (y == null) {
			y = 0;
		}
		
		if (!useTexturePacker) {
			return new FlxSprite(x, y, assetPath);
		}
		
		var frame = getFrame(assetPath);
		var sprite = new FlxSprite(x, y);
		sprite.frame = frame;
		return sprite;
	}
	
	public static function getGraphicAsset(assetPath:String):FlxGraphicAsset {
		if (!useTexturePacker) {
			return assetPath;
		}
		
		return FlxGraphic.fromFrame(getFrame(assetPath));
	}
	
	private static function getFrame(assetPath:String):FlxFrame {		
		var i = assetPath.lastIndexOf("/");
		var frame = null;
		if (i > 0) {
			var fileName = assetPath.substring(i + 1);
			for (atlas in atlases) {
				if (atlas.framesHash.exists(fileName)) {
					frame = atlas.getByName(fileName);
					break;
				}
			}
		}
		
		if (frame == null || i <= 0) {
			trace("Failed to get frame for: " + assetPath);
		}
		
		return frame;
	}
}