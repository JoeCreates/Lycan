package lycan.util;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.Assets;

// TODO asset paths will need substituting for localization at some point, maybe (full event-based reloading would be better though). Could do that here or elsewhere...
// TODO no need for this to be static, could pass params via c'tor - can always stick it on a singleton anyway...

/**
 * Provides an abstraction for switching between loading of loose image assets and packed images.
 * Useful when using loose images during development, and packed images for test and release builds.
 */
class ImageLoader {
	/**
	 * Whether to use packed textures.
	 */
	#if texturepacker
	private static var useTexturePacker:Bool = true;
	#else
	private static var useTexturePacker:Bool = false;
	#end
	
	/**
	 * Loose image path that needs to be set to use the ImageLoader when the texture packer is disabled. Requires trailing slash, no leading slash.
	 */
	public static var defaultLooseImagePath(default, set):String = null;
	
	/**
	 * Loaded atlas textures.
	 */
	private static var atlases:Array<FlxAtlasFrames> = new Array<FlxAtlasFrames>();
	
	/**
	 * Loads an image atlas.
	 * @param	fileName	The file name of the image atlas and sheet data, without file extension e.g. "atlas0".
	 * @param	atlasPath	Optional file path to the image atlas, with trailing slash e.g. "assets/atlases/".
	 * @param	atlasFileExt	Optional file extension of the atlas file e.g. ".png".
	 * @param	sheetDataPath	Optional file path to the sheet data file e.g. "assets/data/".
	 * @param	sheetDataFileExt	Optional file extension of the sheet data file e.g. ".json"
	 * @return	Atlas frames for the given parameters.
	 */
	public static function loadAtlas(fileName:String, atlasPath:String = "assets/images/texturepacker/", atlasFileExt:String = ".png", sheetDataPath:String = "assets/data/texturepacker/", sheetDataFileExt:String = ".json"):FlxAtlasFrames {
		var frames = FlxAtlasFrames.fromTexturePackerJson(atlasPath + fileName + atlasFileExt, Assets.getText(sheetDataPath + fileName + sheetDataFileExt));
		Sure.sure(frames != null);
		atlases.push(frames);
		return frames;
	}
	
	/**
	 * Gets a new FlxSprite, sourcing the image data from an image atlas (unless the texture packer is disabled).
	 * @param	x	The initial x-coordinate of the sprite.
	 * @param	y	The initial y-coordinate of the sprite.
	 * @param	fileName	The image filename, with file extension e.g. "clocktower.png".
	 * @param	looseImagePath	Optional file path to the loose image, overriding the default loose image path, with trailing slash e.g. "assets/images/preloader/".
	 * @return	A new FlxSprite for the given parameters.
	 */
	public static function getSprite(x:Null<Float> = 0.0, y:Null<Float> = 0.0, fileName:String, ?looseImagePath:String):FlxSprite {
		Sure.sure(fileName != null && fileName.length > 0);
		
		if (!useTexturePacker) {
			if (looseImagePath == null) {
				looseImagePath = ImageLoader.defaultLooseImagePath;
			}
			Sure.sure(looseImagePath != null && looseImagePath.length > 0);
			return new FlxSprite(x, y, looseImagePath + fileName);
		}
		var frame = getFrame(fileName);
		var sprite = new FlxSprite(x, y);
		sprite.frame = frame;
		sprite.updateHitbox();
		return sprite;
	}
	
	/**
	 * Gets a new FlxGraphicAsset, returning a FlxGraphic for an image atlas, or a path to a loose image if the texture packer is disabled.
	 * @param	fileName	The image filename, without file extension e.g. "clocktower.png".
	 * @param	looseImagePath	Optional file path to the loose image, overriding the default loose image path e.g. "assets/images/preloader/".
	 * @return	A new FlxGraphicAsset for the given parameters.
	 */
	public static function getGraphicAsset(fileName:String, ?looseImagePath:String):FlxGraphicAsset {
		Sure.sure(fileName != null && fileName.length > 0);
		
		if (!useTexturePacker) {
			if (looseImagePath == null) {
				looseImagePath = ImageLoader.defaultLooseImagePath;
			}
			Sure.sure(looseImagePath != null && looseImagePath.length > 0);
			return looseImagePath + fileName;
		}
		return FlxGraphic.fromFrame(getFrame(fileName));
	}
	
	private static inline function getFrame(fileName:String):FlxFrame {
		Sure.sure(fileName != null && fileName.length > 0);
		
		var frame = null;
		for (atlas in atlases) {
			if (atlas.framesHash.exists(fileName)) {
				frame = atlas.getByName(fileName);
				break;
			}
		}
		Sure.sure(frame != null);
		return frame;
	}
	
	private static function set_defaultLooseImagePath(path:String):String {
		Sure.sure(path != null && path.length > 0 && path.charAt(path.length - 1) == "/");
		return ImageLoader.defaultLooseImagePath = path;
	}
}