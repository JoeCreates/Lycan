package lycan.world.layer;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import lycan.world.layer.ILayer.LayerType;

typedef TileLayer = TypedTileLayer<FlxTilemap>;

class TypedTileLayer<T:FlxTilemap> implements ILayer {
	public var tilemap:T;
	
	public var layerType(default, null):LayerType = LayerType.TILE;
	public var world(default, null):World;
	public var tileWidth(get, null):Float;
	public var tileHeight(get, null):Float;
	
	public var properties:TiledPropertySet;
	
	public function new(world:World) {
		this.world = world;
	}
	
	public function load(tiledLayer:TiledTileLayer, tilemap:T):TypedTileLayer<T> {
		this.tilemap = tilemap;
		tilemap.loadMapFromArray(tiledLayer.tileArray, tiledLayer.map.width, tiledLayer.map.height, world.combinedTileset,
			Std.int(tiledLayer.map.tileWidth), Std.int(tiledLayer.map.tileHeight), FlxTilemapAutoTiling.OFF, 1, 1, 1);
		tilemap.scale.copyFrom(world.scale);
		tilemap.pixelPerfectPosition = true;
		tilemap.pixelPerfectRender = true;
		this.tileWidth = tiledLayer.map.tileWidth;
		this.tileHeight = tiledLayer.map.tileHeight;
		
		this.properties = tiledLayer.properties;
		processProperties(tiledLayer);
		
		return this;
	}
	
	public function processProperties(tiledLayer:TiledLayer):TypedTileLayer<T> {
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
		
		return this;
	}
	
	public function getBasic():FlxBasic {
		return tilemap;
	}
	
	private function get_tileWidth():Float {
		return tileWidth * tilemap.scale.x;
	}
	
	private function get_tileHeight():Float {
		return tileHeight * tilemap.scale.y;
	}
}

//class NapeTileLayer extends TileLayer {
	//public var tilemap:FlxNapeTilemap;
	//
	//public function new(world:World, tileWidth:Float, tileHeight:Float) {
		//super(world, tileWidth, tileHeight);
	//}
//}