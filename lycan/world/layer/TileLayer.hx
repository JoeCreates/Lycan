package lycan.world.layer;

import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSignal.FlxTypedSignal;
import lycan.world.TileLayerLoader.TileLayerHandler;
import lycan.world.layer.ILayer.LayerType;

@:access(flixel.tile.FlxTilemap)
class TileLayer implements ILayer {
	public var type(default, null):LayerType = LayerType.TILE;
	public var tilemap(default, null):FlxTilemap;
	public var world(default, null):World;
	public var tileWidth(get, null):Float;
	public var tileHeight(get, null):Float;
	public var data(get, set):Array<Int>;
	
	public var loaded:FlxTypedSignal<TiledTileLayer->Void>;
	
	public var properties:TiledPropertySet;
	
	public function new(world:World) {
		this.world = world;
		
		tilemap = null;
		loaded = new FlxTypedSignal<TiledTileLayer->Void>();
	}
	
	public function load(tiledLayer:TiledTileLayer, handler:TileLayerHandler):Void {
		tileWidth = tiledLayer.map.tileWidth;
		tileHeight = tiledLayer.map.tileHeight;
		
		properties = tiledLayer.properties;
		
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
	
	private function get_data():Array<Int> {
		return tilemap._data;
	}
	private function set_data(data:Array<Int>):Array<Int> {
		return tilemap._data = data;
	}
}