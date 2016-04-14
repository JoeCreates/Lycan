package lycan.world;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.math.FlxPoint;
import lycan.world.layer.ILayer;
import lycan.world.layer.NapeTileLayer;
import lycan.world.layer.TileLayer.TypedTileLayer;

class NapeWorld extends World {

	public function new(scale:FlxPoint) {
		super(scale);
	}
	
	override public function loadTileLayer(tiledLayer:TiledTileLayer):ILayer {
		var layer:NapeTileLayer = cast new NapeTileLayer(this).load(tiledLayer, new FlxNapeTilemap());
		add(layer.tilemap);
		namedLayers.set(tiledLayer.name, layer);
		return layer;
	}
	
}