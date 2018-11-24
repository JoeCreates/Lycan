package lycan.world;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledMap.FlxTiledMapAsset;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledPropertySet;
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
import lycan.world.ObjectLoader.ObjectHandler;
import lycan.world.TileLayerLoader.TileLayerHandler;
import lycan.world.layer.ILayer;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;
import openfl.display.BitmapData;

// A 2D world built from Tiled maps
// Consists of TileLayers of tiles and ObjectLayers containing game objects
class World extends FlxGroup {
	public var name:String;
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var scale(default, null):FlxPoint;
	
	public var updateSpeed:Float;
	public var namedObjects(default, null):Map<String, FlxBasic>;
	public var namedLayers(default, null):Map<String, ILayer>;
	public var namedTilesets(default, null):Map<String, TiledTileSet>;
	public var collidableTilemaps(default, null):Array<FlxTilemap>;
	
	public var properties:TiledPropertySet;
	public var combinedTileset:FlxTileFrames;
	
	public var onLoadingProgressed(default, null):FlxTypedSignal<Float->Void>;
	
	private static inline var TILESET_PATH = "assets/images/"; // TODO avoid explicit tileset path if possible
	
	public function new(?scale:FlxPoint) {
		super();

		if (scale == null) {
			scale = new FlxPoint(1, 1);
		}
		this.scale = scale;
		name = "Unnamed World";
		updateSpeed = 1;
		namedObjects = new Map<String, FlxBasic>();
		namedLayers = new Map<String, ILayer>();
		namedTilesets = new Map<String, TiledTileSet>();
		collidableTilemaps = new Array<FlxTilemap>();
		
		onLoadingProgressed = new FlxTypedSignal<Float->Void>();
	}
	
	public function collideWithLevel<T, U>(obj:FlxBasic, ?notifyCallback:T->U->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {
		if (collidableTilemaps == null) {
			return false;
		}
		
		for (map in collidableTilemaps) {
			// NOTE Always collide the map with objects, not the other way around
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
				return true;
			}
		}

		return false;
	}
	
	public function load(tiledLevel:FlxTiledMapAsset, objectLoadingHandlers:FlxTypedSignal<ObjectHandler>, tileLayerLoadingHandler:TileLayerHandler):World {
		var tiledMap = new TiledMap(tiledLevel);
		
		width = tiledMap.fullWidth;
		height = tiledMap.fullHeight;
		
		updateCameraAndWorldBounds();
		loadTilesets(tiledMap);
		
		// Load layers
		var layersLoaded:Float = 0;
		for (tiledLayer in tiledMap.layers) {
			switch (tiledLayer.type) {
				case TiledLayerType.OBJECT: loadObjectLayer(cast tiledLayer, objectLoadingHandlers);
				case TiledLayerType.TILE: loadTileLayer(cast tiledLayer, tileLayerLoadingHandler);
				default:
					trace("Encountered unknown TiledLayerType");
			}
			
			var loadingProgressPercent:Float = (layersLoaded / tiledMap.layers.length) * 100;
			onLoadingProgressed.dispatch(loadingProgressPercent);
			layersLoaded++;
		}
		
		return this;
	}
	
	public function loadTileLayer(tiledLayer:TiledTileLayer, handler:TileLayerHandler):ILayer {
		var layer:TileLayer = new TileLayer(this);
		layer.load(tiledLayer, handler);
		add(layer.tilemap);
		namedLayers.set(tiledLayer.name, layer);
		return layer;
	}
	
	public function loadObjectLayer(tiledLayer:TiledObjectLayer, handlers:FlxTypedSignal<ObjectHandler>):ILayer {
		var layer:ObjectLayer = new ObjectLayer(this);
		layer.load(tiledLayer, handlers);
		add(layer.group);
		namedLayers.set(tiledLayer.name, layer);
		return layer;
	}

	override public function update(dt:Float):Void {
		super.update(dt * updateSpeed);
	}
	
	public inline function getObject(name:String):FlxBasic {
		return namedObjects.get(name);
	}
	
	public inline function getLayer(name:String):ILayer {
		return namedLayers.get(name);
	}
	
	public inline function getTileSet(name:String):TiledTileSet {
		return namedTilesets.get(name);
	}
	
	private function loadTilesets(tiledMap:TiledMap):Void {
		// Load tileset graphics
		var tilesetBitmaps:Array<BitmapData> = new Array<BitmapData>();
		for (tileset in tiledMap.tilesetArray) {
			// TODO might require attention later
			if (tileset.properties.contains("noload")) continue;
			var imagePath = new Path(tileset.imageSource);
			var processedPath = TILESET_PATH + imagePath.file + "." + imagePath.ext;
			tilesetBitmaps.push(FlxAssets.getBitmapData(processedPath));
		}
		
		if (tilesetBitmaps.length == 0) {
			throw "Cannot load an empty tilemap, as it will result in invalid bitmap data errors";
		}
		
		// Combine tilesets into single tileset
		var tileSize:FlxPoint = FlxPoint.get(tiledMap.tileWidth, tiledMap.tileHeight);
		var spacing:FlxPoint = FlxPoint.get(2, 2);
		combinedTileset = FlxTileFrames.combineTileSets(tilesetBitmaps, tileSize, spacing, spacing);
		tileSize.put();
		spacing.put();
		
		// Save a reference to the tileset map
		namedTilesets = tiledMap.tilesets;
	}
	
	private function updateCameraAndWorldBounds():Void {
		// Camera scroll bounds
		FlxG.camera.setScrollBoundsRect(0, 0, width * scale.x, height * scale.y, true);
	}
}