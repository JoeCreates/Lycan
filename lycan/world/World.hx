package lycan.world;

import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import haxe.io.Path;
import lycan.world.Layer;
import lycan.world.Layer.TileLayer;
import msignal.Signal.Signal1;
import openfl.display.BitmapData;

typedef WorldObjectLoader = TiledObject->ObjectLayer->FlxBasic;

// A 2D world built from Tiled maps
// Consists of TileLayers and FlxGroups of game objects
class World extends FlxGroup {
	private static inline var TILESET_PATH = "assets/images/"; // TODO avoid explicit path if possible
	
	// Property keys
	private static inline var WORLD_NAME = "name";
	
	public var name(default, null):String;
	public var scale(default, null):FlxPoint;
	public var updateSpeed:Float;
	public var signal_loadingProgress(default, null):Signal1<Float>;
	
	private var namedObjects(default, null):Map<String, FlxBasic>;
	private var namedLayers(default, null):Map<String, Layer>;
	private var collidableLayers(default, null):Array<TileLayer>;
	
	public function new(?scale:FlxPoint) {
		super();
		
		if (scale == null) {
			scale = new FlxPoint(1, 1);
		}
		this.scale = scale;
		updateSpeed = 1;
		
		namedObjects = new Map<String, FlxBasic>();
		namedLayers = new Map<String, Layer>();
		collidableLayers = new Array<TileLayer>();
		
		signal_loadingProgress = new Signal1<Float>();
	}
	
	public function load(tiledLevel:FlxTiledAsset, loaderDefinitions:Map<String, WorldObjectLoader>):Void {
		var tiledMap = new TiledMap(tiledLevel);
		
		if (tiledMap.properties != null && tiledMap.properties.contains(WORLD_NAME)) {
			name = tiledMap.properties.get(WORLD_NAME);
		}
		if (name == null) {
			name = "Unnamed World";
		}
		
		// Camera scroll bounds
		FlxG.camera.setScrollBoundsRect(0, 0, tiledMap.fullWidth * scale.x, tiledMap.fullHeight * scale.x, true);
		FlxG.camera.maxScrollY += FlxG.height / 2;
		
		// Load tileset graphics
		var tilesetBitmaps:Array<BitmapData> = new Array<BitmapData>();
		for (tileset in tiledMap.tilesetArray) {
			var imagePath = new Path(tileset.imageSource);
			var processedPath = TILESET_PATH + imagePath.file + "." + imagePath.ext;
			tilesetBitmaps.push(FlxAssets.getBitmapData(processedPath));
		}
		
		if (tilesetBitmaps.length == 0) {
			throw "Cannot load an empty tilemap, as it will result in invalid bitmap data errors";
		}
		
		// Combine tilesets into single tileset
		var tileSize:FlxPoint = FlxPoint.get(tiledMap.tileWidth, tiledMap.tileHeight);
		var combinedTileset:FlxTileFrames = FlxTileFrames.combineTileSets(tilesetBitmaps, tileSize);
		tileSize.put();
		
		// Load layers
		var layersLoaded:Float = 0;
		for (tiledLayer in tiledMap.layers) {
			switch (tiledLayer.type) {
				case TiledLayerType.OBJECT:					
					var group:ObjectLayer = new ObjectLayer(this);
					World.loadObjectLayer(group, cast tiledLayer, loaderDefinitions);
					namedLayers.set(tiledLayer.name, group);
					for (m in group) {
						if (Std.is(m, FlxObject)) {
							var o = cast (m, FlxObject);
							o.x *= scale.x;
							o.y *= scale.y;
						}
					}
					add(group);
				case TiledLayerType.TILE:
					var layer:TileLayer = new TileLayer(this);
					var tileLayer:TileLayer = loadTileLayer(layer, scale, collidableLayers, tiledMap, cast tiledLayer, combinedTileset);
					namedLayers.set(tiledLayer.name, tileLayer);
					add(tileLayer);
				default:
					trace("Encountered unknown TiledLayerType");
			}
			
			var loadingProgressPercent:Float = (layersLoaded / tiledMap.layers.length) * 100;
			signal_loadingProgress.dispatch(loadingProgressPercent);
			layersLoaded++;
		}
	}
	
	public function collideWithLevel<T, U>(obj:FlxBasic, ?notifyCallback:T->U->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {
		if (collidableLayers == null) {
			return false;
		}
		
		for (map in collidableLayers) {
			// NOTE Always collide the map with objects, not the other way around
			if(FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
				return true;
			}
		}
		
		return false;
	}
	
	// Implements loading of tiles into a world from a TiledMap
	private static function loadTileLayer(layer:TileLayer, scale:FlxPoint, collidableLayers:Array<TileLayer>, tiledMap:TiledMap, tiledLayer:TiledTileLayer, combinedTileset:FlxTilemapGraphicAsset):TileLayer {
		layer.loadMapFromArray(tiledLayer.tileArray, tiledMap.width, tiledMap.height, combinedTileset, Std.int(tiledMap.tileWidth), Std.int(tiledMap.tileHeight), FlxTilemapAutoTiling.OFF, 1, 1, 1);
		layer.scale.copyFrom(scale);
		
		// Collidable layers
		if (tiledLayer.properties.contains("collision")) {
			layer.solid = true;
			collidableLayers.push(layer);
			if (tiledLayer.properties.get("collision") == "oneway") {
				layer.allowCollisions = FlxObject.UP;
			}
		}
		
		// TODO implement this using passed-in handler functions like objects
		if (tiledLayer.properties.contains("hide")) {
			layer.visible = false;
		}
		
		return layer;
	}
	
	// Implements loading of objects into a world from a TiledMap using supplied handler functions (world object loaders)
	// Load the objects from a tiled map into a world 
	// @param	layer The layer into which objects will be loaded
	// @param	tiledLayer The Tiled layer data from which the world will be loaded
	private static function loadObjectLayer(layer:ObjectLayer, tiledLayer:TiledObjectLayer, loaderDefinitions:Map<String, WorldObjectLoader>):Void {
		for (o in tiledLayer.objects) {
			if (!loaderDefinitions.exists(o.type)) {
				throw ("Error loading world. Unknown object type: " + o.type);
			}
			
			// Call the loader function for that type with the object data
			var basic:FlxBasic = loaderDefinitions.get(o.type)(o, layer);
			
			// Set the basic name to the object name
			if (o.name != null) {
				layer.world.namedObjects.set(o.name, basic);
			}
			
			// Add the basic to the layer if it exists
			if (basic != null) {
				layer.add(basic);
			}
		}
	}
	
	override public function update(dt:Float):Void {
		super.update(dt * updateSpeed);
	}
	
	public inline function getNamedObject(name:String):FlxBasic {
		return namedObjects.get(name);
	}
	
	public inline function getNamedLayer(name:String):Layer {
		return namedLayers.get(name);
	}
}