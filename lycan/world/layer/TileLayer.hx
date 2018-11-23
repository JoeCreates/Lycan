package lycan.world.layer;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.math.FlxRect;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.util.FlxSignal.FlxTypedSignal;
import lycan.world.layer.ILayer.LayerType;
import flixel.math.FlxPoint;
import lycan.util.GraphicUtil;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;

@:access(flixel.tile.FlxTilemap)
class TileLayer implements ILayer {
	public var layerType(default, null):LayerType = LayerType.TILE;
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
	
	public function load(tiledLayer:TiledTileLayer):Void {
		
		//TODO do this with flag in map
		var auto:Bool = true;
		//TODO read this from the map?
		var autoTiles:BitmapData = GraphicUtil.scaleBitmapData(FlxAssets.getBitmapFromClass(GraphicAutoFull), 1);
		if (auto) {
			
		}
		
		// TODO either nape or regular tilemap based on properties?
		tilemap = new FlxTilemap();
		//TODO hacked in scale
		tilemap.loadMapFromArray(tiledLayer.tileArray, tiledLayer.map.width, tiledLayer.map.height, autoTiles,
			Std.int(tiledLayer.map.tileWidth), Std.int(tiledLayer.map.tileHeight), FlxTilemapAutoTiling.FULL, 1, 1, 1);
		
		tilemap.scale.copyFrom(world.scale);
		tileWidth = tiledLayer.map.tileWidth;
		tileHeight = tiledLayer.map.tileHeight;
		
		properties = tiledLayer.properties;
		processProperties(tiledLayer);
		
		loaded.dispatch(tiledLayer);
	}
	
	public function processProperties(tiledLayer:TiledLayer):Void {
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