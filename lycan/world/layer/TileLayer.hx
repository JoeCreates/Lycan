package lycan.world.layer;

import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import lycan.world.TileLayerLoader.TileLayerHandler;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSignal.FlxTypedSignal;
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
	
	public function load(tiledLayer:TiledTileLayer, handlers:FlxTypedSignal<TileLayerHandler>):Void {
		tileWidth = tiledLayer.map.tileWidth;
		tileHeight = tiledLayer.map.tileHeight;
		
		properties = tiledLayer.properties;
		processProperties(tiledLayer);
		
		// TODO either nape, regular or other tilemap based on global properties, then map/world properties, then layer properties
		tilemap = new FlxTilemap();

		// TODO decide scale based on layer info/properties?
		// TODO decide whether to do autotiling based on the map?
		// NOTE using using embedded assets is broken on html5 (TODO - don't hardcode autotile path)
		tilemap.loadMapFromArray(tiledLayer.tileArray, tiledLayer.map.width, tiledLayer.map.height, "assets/images/autotiles_full.png",
			Std.int(tiledLayer.map.tileWidth), Std.int(tiledLayer.map.tileHeight), FlxTilemapAutoTiling.FULL, 1, 1, 1);
		
		tilemap.scale.copyFrom(world.scale);
		
		loaded.dispatch(tiledLayer);
	}
	
	public function processProperties(tiledLayer:TiledLayer):Void {
		// TODO handle properties in loader
		if (tiledLayer.properties.contains("collides")) {
			tilemap.solid = true;
			world.collidableTilemaps.push(tilemap);
			if (tiledLayer.properties.get("collides") == "oneway") {
				tilemap.allowCollisions = FlxObject.UP;
			}
		}
		if (tiledLayer.properties.contains("hidden")) {
			tilemap.visible = false;
		}
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