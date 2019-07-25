package lycan.world;

import nape.dynamics.InteractionGroup;
import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledMap.FlxTiledMapAsset;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledImageLayer;
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
import lycan.world.layer.PhysicsTileLayer;
import lycan.world.layer.ImageLayer;
import lycan.world.WorldHandlers;
import nape.phys.Material;
import lycan.phys.Phys;
import flixel.addons.editors.tiled.TiledMap;

//TODO
typedef Tileset = TiledTileSet;

class TiledWorld extends FlxGroup {
	
	public var objects = new Map<Int, Dynamic>();
	public var objectLayers = new Map<String, ObjectLayer>();
	public var tileLayers = new Map<String, TileLayer>();
	public var imageLayers = new Map<String, ImageLayer>();
	public var tilesets = new Map<String, Tileset>();
	public var collisionGroups = new Map<String, InteractionGroup>();
	
	public var objectHandlers:ObjectHandlers;
	public var layerLoadedHandlers:LayerLoadedHandlers;
	
	public var combinedTileset:FlxTileFrames;
	
	public var defaultCollisionType:WorldCollisionType;
	
	public var width:Float;
	public var height:Float;
	public var scale:FlxPoint;
	
	/**
	 *  Array of tilemaps to use for flixel base collision detection
	 */
	public var collisionLayers:Array<FlxTilemap>;
	
	public var onLoadingProgressed(default, null) = new FlxTypedSignal<Float->Void>();
	public var onLoadingComplete(default, null) = new FlxTypedSignal<Void->Void>();

	public function new(scale:Float = 1, defaultCollisionType:WorldCollisionType = ARCADE) {
		super();
		collisionLayers = [];
		this.scale = FlxPoint.get(scale, scale);
		objectHandlers = new ObjectHandlers();
		layerLoadedHandlers = new LayerLoadedHandlers();
		this.defaultCollisionType = defaultCollisionType;
	}
	
	override function destroy() {
		super.destroy();
		objects = null;
		objectLayers = null;
		tileLayers = null;
		imageLayers = null;
		scale.put();
		scale = null;
		combinedTileset.destroy();
		combinedTileset = null;
		collisionLayers.splice(0, collisionLayers.length);
	}
	
	public function collideWithLevel<T, U>(obj:FlxBasic, ?notifyCallback:T->U->Void, ?processCallback:T->U->Bool):Bool {
		if (collisionLayers == null) return false;
		
		for (map in collisionLayers) {
			// NOTE Always collide the map with objects, not the other way around
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
				return true;
			}
		}

		return false;
	}
	
	//TODO could improve by having prehandler for layers similar to nape?
	public function load(tiledMap:TiledMap, ?objectHandlers:ObjectHandlers, ?layerLoadedHandlers:LayerLoadedHandlers, ?defaultCollisionType:WorldCollisionType):Void {
		if (objectHandlers == null) objectHandlers = this.objectHandlers;
		if (layerLoadedHandlers == null) layerLoadedHandlers = this.layerLoadedHandlers;
		if (defaultCollisionType == null) defaultCollisionType = this.defaultCollisionType;
		
		var properties = tiledMap.properties;
		width = tiledMap.fullWidth;
		height = tiledMap.fullHeight;
		
		// Default collision type
		if (properties.contains("defaultCollisionType")) {
			var val:String = properties.get("defaultCollisionType");
			switch (val.toLowerCase()) {
				case WorldCollisionType.ARCADE:
					defaultCollisionType = WorldCollisionType.ARCADE;
				case WorldCollisionType.PHYSICS:
					defaultCollisionType = WorldCollisionType.PHYSICS;
				case _:
					trace("Invalid deault collision type: " + val);
			}
		}
		
		// Load tileset graphics
		loadTileSets(tiledMap);
		
		// Load layers
		var layersLoaded:Float = 0;
		for (tiledLayer in tiledMap.layers) {
			var layer:WorldLayer;
			// Load each layer by layer type
			switch (tiledLayer.type) {
				case TiledLayerType.OBJECT: {
					layer = loadObjectLayer(cast tiledLayer, objectHandlers);
					objectLayers.set(tiledLayer.name, cast layer);
				}
				case TiledLayerType.TILE: {
					layer = loadTileLayer(cast tiledLayer, defaultCollisionType);
					tileLayers.set(tiledLayer.name, cast layer);
				}
				case TiledLayerType.IMAGE: {
					layer = loadImageLayer(cast tiledLayer);
					imageLayers.set(tiledLayer.name, cast layer);
				}
				default:
					throw("Encountered unsupported Tiled layer type");
			}
			
			// Call post-load handlers
			layerLoadedHandlers.dispatch(tiledLayer, layer);
			
			// Track loading progress
			var loadingProgressPercent:Float = (layersLoaded / tiledMap.layers.length) * 100;
			onLoadingProgressed.dispatch(loadingProgressPercent);
			layersLoaded++;
		}
		
		onLoadingComplete.dispatch();
	}
	
	private function loadTileSets(tiledMap:TiledMap):Void {
		var tilesetBitmaps = new Array<BitmapData>();
		for (tileset in tiledMap.tilesetArray) {
			if (tileset.properties.contains("nontile") || tileset.properties.contains("noload")) {
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
		combinedTileset = FlxTileFrames.combineTileSets(tilesetBitmaps, tileSize, spacing, spacing);
		tileSize.put();
		spacing.put();
		
		tilesets = tiledMap.tilesets;
	}
	
	private function loadImageLayer(tiledLayer:TiledImageLayer):ImageLayer {
		// If it's a submap TODO
		
		// If it's an image
		// TODO could do better path handling
		var layer = new ImageLayer(this, tiledLayer);
		var imagePath = new Path(tiledLayer.imagePath);
		var processedPath = "assets/images/" + imagePath.file + "." + imagePath.ext;
		layer.loadGraphic(processedPath);
		layer.setPosition(tiledLayer.x, tiledLayer.y);
		add(layer);
		return layer;
	}
	
	private function loadObjectLayer(tiledLayer:TiledObjectLayer, handlers:ObjectHandlers):ObjectLayer {
		var layer = new ObjectLayer(this, tiledLayer);
		layer.loadObjects(tiledLayer, handlers);
		objectLayers.set(tiledLayer.name, layer);
		add(layer);
		return layer;
	}
	
	private function loadTileLayer(tiledLayer:TiledTileLayer, defaultCollisionType:WorldCollisionType):TileLayer {
		// By default, use world's physics setting
		var collisionType:WorldCollisionType = defaultCollisionType;
		
		// But override with physics setting of individual tile layer if set
		if (tiledLayer.properties.contains("collisionType")) {
			collisionType = tiledLayer.properties.get("collisionType");
		}
		
		var tileLayer:TileLayer = collisionType == "physics" ? new PhysicsTileLayer(this, tiledLayer) : new TileLayer(this, tiledLayer);
		
		if (tileLayer.properties.contains("hidden")) {
			tileLayer.visible = false;
		}
		
		tileLayers.set(tiledLayer.name, tileLayer);
		add(tileLayer);
		return tileLayer;
	}
	
}

@:enum abstract WorldCollisionType(String) from String to String {
	public var PHYSICS = "physics";
	public var ARCADE = "arcade";
	public var NONE = "none";
}

class WorldLoaderPresets {
	
	//public static function 
}