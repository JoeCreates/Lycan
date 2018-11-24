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
import flixel.tile.FlxTilemap;
import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.ds.Map;
import lycan.world.ObjectLoader.ObjectHandler;
import lycan.world.TileLayerLoader.TileLayerHandler;
import lycan.world.TileSetLoader.TileSetHandler;
import lycan.world.layer.ILayer;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;

// A 2D world built from Tiled maps
// Consists of TileLayers of tiles and ObjectLayers containing game objects
class World extends FlxGroup {
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var scale(default, null):FlxPoint;
	public var properties(default, null):TiledPropertySet;
	
	public var updateSpeed:Float;
	public var namedLayers:Map<String, ILayer>;
	public var namedTilesets:Map<String, TiledTileSet>;
	public var collidableTilemaps:Array<FlxTilemap>;
	
	public var combinedTileset:FlxTileFrames;
	
	public var onLoadedObjectLayer(default, null) = new FlxTypedSignal<ObjectLayer->Void>();
	public var onLoadedTileLayer(default, null) = new FlxTypedSignal<TileLayer->Void>();
	public var onLoadingProgressed(default, null) = new FlxTypedSignal<Float->Void>();
	public var onLoadingComplete(default, null) = new FlxTypedSignal<Void->Void>();
	
	public function new(?scale:FlxPoint) {
		super();

		if (scale == null) {
			scale = new FlxPoint(1, 1);
		}
		this.scale = scale;
		updateSpeed = 1;
		namedLayers = new Map<String, ILayer>();
		namedTilesets = new Map<String, TiledTileSet>();
		collidableTilemaps = new Array<FlxTilemap>();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt * updateSpeed);
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
	
	public inline function getLayer(name:String):ILayer {
		return namedLayers.get(name);
	}
	
	public inline function getTileSet(name:String):TiledTileSet {
		return namedTilesets.get(name);
	}
	
	public function load(tiledLevel:FlxTiledMapAsset, tileSetLoadingHandler:TileSetHandler, objectLoadingHandlers:FlxTypedSignal<ObjectHandler>, tileLayerLoadingHandler:TileLayerHandler):Void {
		var tiledMap = new TiledMap(tiledLevel);
		properties = tiledMap.properties;
		width = tiledMap.fullWidth;
		height = tiledMap.fullHeight;
		
		// Load tilesets
		tileSetLoadingHandler(tiledMap);
		
		// Load layers
		var layersLoaded:Float = 0;
		for (tiledLayer in tiledMap.layers) {
			switch (tiledLayer.type) {
				case TiledLayerType.OBJECT: {
					var layer = loadObjectLayer(cast tiledLayer, objectLoadingHandlers);
					onLoadedObjectLayer.dispatch(layer);
				}
				case TiledLayerType.TILE: {
					var layer = loadTileLayer(cast tiledLayer, tileLayerLoadingHandler);
					onLoadedTileLayer.dispatch(layer);
				}
				default:
					trace("Encountered unknown TiledLayerType");
			}
			
			var loadingProgressPercent:Float = (layersLoaded / tiledMap.layers.length) * 100;
			onLoadingProgressed.dispatch(loadingProgressPercent);
			layersLoaded++;
		}
		
		onLoadingComplete.dispatch();
	}
	
	private function loadObjectLayer(tiledLayer:TiledObjectLayer, handlers:FlxTypedSignal<ObjectHandler>):ObjectLayer {
		var layer = new ObjectLayer(this);
		layer.load(tiledLayer, handlers);
		add(layer.group);
		namedLayers.set(tiledLayer.name, layer);
		return layer;
	}
	
	private function loadTileLayer(tiledLayer:TiledTileLayer, handler:TileLayerHandler):TileLayer {
		var layer = new TileLayer(this);
		layer.load(tiledLayer, handler);
		add(layer.tilemap);
		namedLayers.set(tiledLayer.name, layer);
		return layer;
	}
}