package lycan.util;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.system.FlxAssets.FlxGraphicAsset;
import msignal.Signal.Signal1;
import openfl.Assets;

// TODO no need for this to be static, could pass params via c'tor - can always stick it on a singleton anyway...
// TODO should separate the loose asset loading from the packed loading
// TODO should add way for preloader/non-packed assets via a loadLoose-type method (to take advantage of search paths etc)

/**
 * Provides an abstraction for image loading, such as loading of loose image assets and packed images.
 * Useful when using loose images during development, and packed images for test and release builds.
 * Asset search paths are useful for conditional loading of images, or for localization or seasonal events.
 */
class ImageLoader {
	/**
	 * Base path for searching for loose assets.
	 */
	public static var looseBasePath:String = "";
	
	/**
	 * Fires when a search path is added.
	 */
	public static var signal_searchPathAdded(default, null) = new Signal1<String>();
	
	/**
	 * Whether to use packed textures.
	 */
	private static var useTexturePacker:Bool = #if texturepacker true #else false #end;
	
	/**
	 * Paths to search for assets.
	 */
	private static var searchPaths(default, null):Array<String> = [];
	
	/**
	 * Loaded atlas textures.
	 */
	private static var atlases:Array<FlxAtlasFrames> = new Array<FlxAtlasFrames>();
	
	/**
	 * Add an image search path.
	 * @param	path	The path that will be scanned for assets.
	 */
	public static function addSearchPath(path:String):Void {
		searchPaths.insert(0, path);
		signal_searchPathAdded.dispatch(path);
	}
	
	/**
	 * Loads an image atlas.
	 * @param	fileName	The file name of the image atlas and sheet data, without file extension e.g. "atlas0".
	 * @param	atlasPath	Optional file path to the image atlas, with trailing slash e.g. "assets/atlases/".
	 * @param	atlasFileExt	Optional file extension of the atlas file e.g. ".png".
	 * @param	sheetDataPath	Optional file path to the sheet data file e.g. "assets/data/".
	 * @param	sheetDataFileExt	Optional file extension of the sheet data file e.g. ".json"
	 * @return	Atlas frames for the given parameters.
	 */
	public static function loadAtlas(fileName:String, atlasPath:String, atlasFileExt:String, sheetDataPath:String, sheetDataFileExt:String):FlxAtlasFrames {
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
	public static function getSprite(x:Null<Float> = 0.0, y:Null<Float> = 0.0, fileName:String):FlxSprite {
		Sure.sure(fileName != null && fileName.length > 0);
		
		for (searchPath in searchPaths) {
			if (!useTexturePacker) {
				
				if (!Assets.exists(looseBasePath + searchPath + fileName)) {
					continue;
				}
				return new FlxSprite(x, y, looseBasePath + searchPath + fileName);
			}
			var frame = getFrame(searchPath, fileName);
			if (frame == null) {
				continue;
			}
			var sprite = new FlxSprite(x, y);
			sprite.frame = frame;
			sprite.updateHitbox();
			return sprite;
		}
		
		return null;
	}
	
	/**
	 * Gets a new FlxGraphicAsset, returning a FlxGraphic for an image atlas, or a path to a loose image if the texture packer is disabled.
	 * @param	fileName	The image filename, without file extension e.g. "clocktower.png".
	 * @param	looseImagePath	Optional file path to the loose image, overriding the default loose image path e.g. "assets/images/preloader/".
	 * @return	A new FlxGraphicAsset for the given parameters.
	 */
	public static function getGraphicAsset(fileName:String):FlxGraphicAsset {
		Sure.sure(fileName != null && fileName.length > 0);
		
		for (searchPath in searchPaths) {
			if (!useTexturePacker) {
				trace(looseBasePath + searchPath + fileName);
				if (!Assets.exists(looseBasePath + searchPath + fileName)) {
					continue;
				}
				return looseBasePath + searchPath + fileName;
			}
			var frame = getFrame(searchPath, fileName);
			if (frame == null) {
				continue;
			}
			return FlxGraphic.fromFrame(frame);
		}
		
		return null;
	}
	
	private static inline function getFrame(searchPath:String, fileName:String):FlxFrame {
		var frame = null;
		for (atlas in atlases) {
			if (atlas.framesHash.exists(searchPath + fileName)) {
				frame = atlas.getByName(searchPath + fileName);
				break;
			}
		}
		return frame;
	}
}