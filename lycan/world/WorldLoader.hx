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
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import haxe.ds.StringMap;
import haxe.io.Path;
import lycan.world.Layer.ObjectLayer;
import lycan.world.Layer.TileLayer;
import lycan.world.WorldLoader.ObjectRules;
import lycan.world.WorldLoader.TileLayerRules;
import lycan.world.WorldLoader.TileMapRules;
import openfl.display.BitmapData;

typedef ObjectLoader = TiledObject->ObjectLayer->FlxBasic;
typedef ObjectRules = StringMap<ObjectLoader>;

typedef TileLayerLoader = TileLayer->TiledTileLayer->Array<TileLayer>->String->Void;
typedef TileLayerRules = StringMap<TileLayerLoader>;

typedef TileMapLoader = World->String->Void;
typedef TileMapRules = StringMap<TileMapLoader>;

// Encapsulates logic for loading 2D Tiled tilemap objects and layers
class WorldLoader {
	public var objectRules:ObjectRules;
	public var tileLayerRules:TileLayerRules;
	public var tileMapRules:TileMapRules;
	
	private static inline var TILESET_PATH = "assets/images/"; // TODO avoid explicit tileset path if possible
	
	public function new(?objectRules:ObjectRules, ?tileLayerRules:TileLayerRules, ?tileMapRules:TileMapRules) {
		if (objectRules == null) {
			objectRules = new ObjectRules();
		}
		if (tileLayerRules == null) {
			tileLayerRules = new TileLayerRules();
		}
		if (tileMapRules == null) {
			tileMapRules = new TileMapRules();
		}
		
		this.objectRules = objectRules;
		this.tileLayerRules = tileLayerRules;
		this.tileMapRules = tileMapRules;
	}
	
	// Implements Tiled world loading
	// @param	world Optional, the world that will have the Tiled map contents loaded into it
	// @param	tiledLevel The Tiled map asset or asset path that the world will be created from
	// @param	loadingRules A worldLoader containing the rules that determine how the world is loaded
	// @return	Returns a world constructed with the tiledLevel and loadingRules provided.
	public static function load(?world:World, tiledLevel:FlxTiledAsset, loadingRules:WorldLoader):World {
		if (world == null) {
			world = new World();
		}
		
		var tiledMap = new TiledMap(tiledLevel);
		
		world.width = tiledMap.fullWidth;
		world.height = tiledMap.fullHeight;
		
		// Handle top-level map properties
		if (tiledMap.properties != null) {
			for (key in tiledMap.properties.keysIterator()) {
				var loader = loadingRules.tileMapRules.get(key);
				if (loader != null) {
					loader(world, tiledMap.properties.get(key));
				} else {
					trace("Tile Map loader encountered unhandled key: " + key);
				}
			}
		}
		
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
		
		// Save a reference to the tileset map
		world.namedTilesets = tiledMap.tilesets;
		
		// Load layers
		var layersLoaded:Float = 0;
		for (tiledLayer in tiledMap.layers) {
			switch (tiledLayer.type) {
				case TiledLayerType.OBJECT:
					var group:ObjectLayer = new ObjectLayer(world);
					loadObjectLayer(group, cast tiledLayer, loadingRules.objectRules);
					world.namedLayers.set(tiledLayer.name, group);
					for (m in group) {
						if (Std.is(m, FlxObject)) {
							var o = cast (m, FlxObject);
							o.x *= world.scale.x;
							o.y *= world.scale.y;
						}
					}
					world.add(group);
				case TiledLayerType.TILE:
					var layer:TileLayer = new TileLayer(world);
					layer.useScaleHack = true;
					var tileLayer:TileLayer = loadTileLayer(layer, world.scale, world.collidableLayers, tiledMap, cast tiledLayer, combinedTileset, loadingRules.tileLayerRules);
					world.namedLayers.set(tiledLayer.name, tileLayer);
					world.add(tileLayer);
				default:
					trace("Encountered unknown TiledLayerType");
			}
			
			var loadingProgressPercent:Float = (layersLoaded / tiledMap.layers.length) * 100;
			world.signal_loadingProgressed.dispatch(loadingProgressPercent);
			layersLoaded++;
		}
		
		return world;
	}
	
	// Implements loading of tiles into a world from a TiledMap
	public static function loadTileLayer(layer:TileLayer, scale:FlxPoint, collidableLayers:Array<TileLayer>, tiledMap:TiledMap, tiledLayer:TiledTileLayer, combinedTileset:FlxTilemapGraphicAsset, rules:TileLayerRules):TileLayer {
		layer.loadMapFromArray(tiledLayer.tileArray, tiledMap.width, tiledMap.height, combinedTileset, Std.int(tiledMap.tileWidth), Std.int(tiledMap.tileHeight), FlxTilemapAutoTiling.OFF, 1, 1, 1);
		layer.scale.copyFrom(scale);
		
		for (key in tiledLayer.properties.keysIterator()) {
			var loader = rules.get(key);
			if (loader != null) {
				loader(layer, tiledLayer, collidableLayers, tiledLayer.properties.get(key));
			} else {
				trace("Tile layer loader encountered unhandled key: " + key);
			}
		}
		
		return layer;
	}
	
	// Implements loading of objects into a world from a TiledMap using supplied handler functions (world object loaders)
	// Load the objects from a tiled map into a world 
	// @param	layer The layer into which objects will be loaded
	// @param	tiledLayer The Tiled layer data from which the world will be loaded
	// @param	objectRules The loading methods for each object type
	public static function loadObjectLayer(layer:ObjectLayer, tiledLayer:TiledObjectLayer, rules:ObjectRules):Void {
		for (o in tiledLayer.objects) {
			if (!rules.exists(o.type)) {
				throw ("Error loading world. Unknown object type: " + o.type);
			}
			
			// Call the loader function for the given object
			var basic:FlxBasic = rules.get(o.type)(o, layer);
			
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
}