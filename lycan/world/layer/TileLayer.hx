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

class TileLayer extends FlxTilemap implements ILayer {
	
	public var layerType(default, null):LayerType = LayerType.TILE;
	public var world(default, null):World;
	public var tileWidth(get, null):Float;
	public var tileHeight(get, null):Float;
	public var data(get, set):Array<Int>;
	
	public var loaded:FlxTypedSignal<TiledTileLayer->Void>;
	
	public var properties:TiledPropertySet;
	
	public function new(world:World) {
		super();
		this.world = world;
		
		loaded = new FlxTypedSignal<TiledTileLayer->Void>();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
	
	public function load(tiledLayer:TiledTileLayer):Void {
		
		//TODO do this with flag in map
		var auto:Bool = true;
		//TODO read this from the map?
		var autoTiles:BitmapData = GraphicUtil.scaleBitmapData(FlxAssets.getBitmapFromClass(GraphicAutoFull), 1);
		if (auto) {
			
		}
		
		//TODO hacked in scale
		loadMapFromArray(tiledLayer.tileArray, tiledLayer.map.width, tiledLayer.map.height, autoTiles,
			Std.int(tiledLayer.map.tileWidth), Std.int(tiledLayer.map.tileHeight), FlxTilemapAutoTiling.FULL, 1, 1, 1);
		
		scale.copyFrom(world.scale);
		tileWidth = tiledLayer.map.tileWidth;
		tileHeight = tiledLayer.map.tileHeight;
		
		properties = tiledLayer.properties;
		processProperties(tiledLayer);
		
		loaded.dispatch(tiledLayer);
	}
	
	public function processProperties(tiledLayer:TiledLayer):Void {
		if (tiledLayer.properties.contains("collides")) {
			solid = true;
			world.collidableTilemaps.push(this);
			if (tiledLayer.properties.get("collides") == "oneway") {
				allowCollisions = FlxObject.UP;
			}
		}
		if (tiledLayer.properties.contains("hidden")) {
			visible = false;
		}
	}
	
	private function get_tileWidth():Float {
		return tileWidth * scale.x;
	}
	
	private function get_tileHeight():Float {
		return tileHeight * scale.y;
	}
	
	private function get_data():Array<Int> {
		return _data;
	}
	private function set_data(data:Array<Int>):Array<Int> {
		return _data = data;
	}
}