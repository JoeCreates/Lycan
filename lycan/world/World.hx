package lycan.world;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledMap.FlxTiledMapAsset;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.ds.Map;
import haxe.io.Path;
import lycan.world.WorldHandlers;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;
import lycan.world.WorldHandlers;

// A 2D world built from Tiled maps
class World extends FlxGroup {
	public var width(default, null):Int = 0;
	public var height(default, null):Int = 0;
	public var scale(default, null):FlxPoint = null;
	public var properties(default, null):Map<String, String> = null;
	public var updateSpeed:Float = 1;
	
	public var namedObjects = new Map<String, FlxBasic>();
	public var namedObjectLayers = new Map<String, ObjectLayer>();
	public var namedTileLayers = new Map<String, TileLayer>();
	public var namedTileSets = new Map<String, TiledTileSet>();
	public var combinedTileSet:FlxTileFrames = null;
	
	public var onLoadingProgressed(default, null) = new FlxTypedSignal<Float->Void>();
	public var onLoadingComplete(default, null) = new FlxTypedSignal<Void->Void>();

	public function new(?scale:FlxPoint) {
		super();
		
		if (scale == null) {
			scale = new FlxPoint(1, 1);
		}
		this.scale = scale;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt * updateSpeed);
	}
	
	public static function collideWithLevel<T, U>(tilemaps:Array<FlxTilemap>, obj:FlxBasic, ?notifyCallback:T->U->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {
		if (tilemaps == null) {
			return false;
		}
		
		for (map in tilemaps) {
			// NOTE Always collide the map with objects, not the other way around
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
				return true;
			}
		}

		return false;
	}
	
	public function load(tiledMap:TiledMap, objectHandlers:ObjectHandlers, objectLayerHandlers:ObjectLayerHandlers,
		tileLayerHandler:TileLayerHandler, worldHandlers:WorldHandlers):Void
	{
		properties = tiledMap.properties.keys;
		width = tiledMap.fullWidth;
		height = tiledMap.fullHeight;
		
		// Load tileset graphics
		loadTileSets(tiledMap);
		
		// Load layers
		var layersLoaded:Float = 0;
		for (tiledLayer in tiledMap.layers) {
			switch (tiledLayer.type) {
				case TiledLayerType.OBJECT: {
					var layer = loadObjectLayer(cast tiledLayer, objectHandlers);
					objectLayerHandlers.dispatch(cast tiledLayer, layer);
				}
				case TiledLayerType.TILE: {
					var layer = loadTileLayer(cast tiledLayer, tileLayerHandler);
				}
				default:
					throw("Encountered unsupported Tiled layer type");
			}
			
			var loadingProgressPercent:Float = (layersLoaded / tiledMap.layers.length) * 100;
			onLoadingProgressed.dispatch(loadingProgressPercent);
			layersLoaded++;
		}
		
		worldHandlers.dispatch(tiledMap, this);
		onLoadingComplete.dispatch();
	}
	
	private function loadTileSets(tiledMap:TiledMap):Void {
		var tilesetBitmaps = new Array<BitmapData>();
		for (tileset in tiledMap.tilesetArray) {
			if (tileset.properties.contains("noload")) {
				continue;
			}
			var imagePath = new Path(tileset.imageSource);
			var processedPath = "assets/images/" + imagePath.file + "." + imagePath.ext;
			tilesetBitmaps.push(FlxAssets.getBitmapData(processedPath));
		}
		
		if (tilesetBitmaps.length == 0) {
			throw "Cannot load an empty tilemap, as it will result in invalid bitmap data errors";
		}
		
		// Combine tilesets into single tileset
		var tileSize:FlxPoint = FlxPoint.get(tiledMap.tileWidth, tiledMap.tileHeight);
		var spacing:FlxPoint = FlxPoint.get(2, 2);
		combinedTileSet = FlxTileFrames.combineTileSets(tilesetBitmaps, tileSize, spacing, spacing);
		tileSize.put();
		spacing.put();
		
		namedTileSets = tiledMap.tilesets;
	}
	
	private function loadObjectLayer(tiledLayer:TiledObjectLayer, handlers:ObjectHandlers):ObjectLayer {
		var layer = new ObjectLayer(this);
		layer.load(tiledLayer, handlers);
		add(layer.group);
		namedObjectLayers.set(tiledLayer.name, layer);
		return layer;
	}
	
	private function loadTileLayer(tiledLayer:TiledTileLayer, handler:TileLayerHandler):TileLayer {
		var layer = new TileLayer(this);
		layer.load(tiledLayer, handler);
		add(layer.tilemap);
		namedTileLayers.set(tiledLayer.name, layer);
		return layer;
	}
}