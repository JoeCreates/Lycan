package lycan.world;

import flixel.tile.FlxTilemap;
import lycan.world.WorldLayer.WorldLayerType;

class TileLayer extends FlxTilemap implements WorldLayer {
	
	public var layerType:WorldLayerType = WorldLayerType.TILE;
	
	public var world:World;
	
	public function new(world:World) {
		super();
		this.world = world;
	}
}