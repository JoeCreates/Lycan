package lycan.world.layer;

import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSignal.FlxTypedSignal;
import lycan.world.TileLayerHandler;
import lycan.world.layer.ILayer.LayerType;

@:access(flixel.tile.FlxTilemap)
class TileLayer implements ILayer {
	public var type(default, null):LayerType = LayerType.TILE;
	public var tilemap(default, null):FlxTilemap = null;
	public var world(default, null):World;
	public var tileWidth(get, never):Float;
	public var tileHeight(get, never):Float;
	
	public var loaded:FlxTypedSignal<TiledTileLayer->Void> = new FlxTypedSignal<TiledTileLayer->Void>();
	
	public var properties:Map<String, String>;
	
	public function new(world:World) {
		this.world = world;
	}
	
	public function load(tiledLayer:TiledTileLayer, handler:TileLayerHandler):Void {
		properties = tiledLayer.properties.keys;
		
		tilemap = handler(tiledLayer, this);
		Sure.sure(tilemap != null);
		
		loaded.dispatch(tiledLayer);
	}
	
	private function get_tileWidth():Float {
		return tilemap._tileWidth * tilemap.scale.x;
	}
	
	private function get_tileHeight():Float {
		return tilemap._tileHeight * tilemap.scale.y;
	}
}