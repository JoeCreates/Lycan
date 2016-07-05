package lycan.world.layer;

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
import flixel.FlxComponent;
import lycan.world.components.NapeTilemapComponent;
import lycan.world.layer.ILayer.LayerType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import flixel.math.FlxPoint;
import lycan.world.components.NapeComponent;

class TileLayer extends FlxTilemap implements ILayer {
	
	public var layerType(default, null):LayerType = LayerType.TILE;
	public var world(default, null):World;
	public var tileWidth(get, null):Float;
	public var tileHeight(get, null):Float;
	public var data(get, set):Array<Int>;
	
	public var loaded:FlxTypedSignal<TiledTileLayer->Void>;
	
	#if nape
		public var nape:NapeComponent;
		public var napeTilemap:NapeTilemapComponent;
	#end
	
	public var properties:TiledPropertySet;
	
	public function new(world:World) {
		super();
		this.world = world;
		
		loaded = new FlxTypedSignal<TiledTileLayer->Void>();
		
		#if nape
			nape = new NapeComponent(BodyType.KINEMATIC, false, false);
			nape.entity = this;
			napeTilemap = new NapeTilemapComponent();
			napeTilemap.entity = this;
		#end
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
	
	public function load(tiledLayer:TiledTileLayer):TileLayer {
		loadMapFromArray(tiledLayer.tileArray, tiledLayer.map.width, tiledLayer.map.height, world.combinedTileset,
			Std.int(tiledLayer.map.tileWidth), Std.int(tiledLayer.map.tileHeight), FlxTilemapAutoTiling.OFF, 1, 1, 1);
		scale.copyFrom(world.scale);
		tileWidth = tiledLayer.map.tileWidth;
		tileHeight = tiledLayer.map.tileHeight;
		
		properties = tiledLayer.properties;
		processProperties(tiledLayer);
		
		loaded.dispatch(tiledLayer);
		
		return this;
	}
	
	public function processProperties(tiledLayer:TiledLayer):TileLayer {
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
		
		return this;
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