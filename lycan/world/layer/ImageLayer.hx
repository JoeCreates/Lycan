package lycan.world.layer;

import flixel.FlxBasic;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.group.FlxGroup;
import lycan.world.WorldHandlers;
import lycan.world.TiledWorld;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxSprite;
import lycan.world.WorldLayer;
import flixel.addons.editors.tiled.TiledImageLayer;

class ImageLayer extends FlxSprite implements WorldLayer {
	public function new(world:TiledWorld, tiledLayer:TiledImageLayer) {
		super();
		worldLayer.init(tiledLayer, world);
	}
	
}